import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/services/cycle_service.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/db_helper.dart';
import '../../core/utils/date_utils.dart';
import '../models/cycle_model.dart';
import '../models/day_info_model.dart';
import '../models/settings_model.dart';
import '../models/user_model.dart';
import 'daily_log_repository.dart';
import 'settings_repository.dart';

abstract class CycleRepository {
  Future<UserModel> getUser();
  Future<CycleModel?> getCurrentCycle();
  Future<List<DayInfoModel>> getMonthDays(DateTime month);
  Future<double?> getTodayBasalTemperature();
  Future<void> saveCycle(CycleModel cycle);
  Future<void> syncLocalToFirebase();
}

class CycleRepositoryImpl implements CycleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SettingsRepository _settingsRepository = SettingsRepositoryImpl();
  final DailyLogRepository _dailyLogRepository = DailyLogRepositoryImpl();

  @override
  Future<UserModel> getUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          return UserModel.fromMap({
            'firstName': data['first_name'] ?? 'Hajar',
            'lastName': data['last_name'] ?? '',
            'profileImageUrl': data['profile_image_url'],
            'hasUnreadNotifications': data['has_unread_notifications'] ?? false,
            'unreadNotificationCount': data['unread_notification_count'] ?? 0,
          });
        }
      } catch (e) {
        debugPrint("Erreur de récupération utilisateur en ligne : $e");
      }
    }
    return const UserModel(
      hasUnreadNotifications: false,
      unreadNotificationCount: 0,
    );
  }

  @override
  Future<CycleModel?> getCurrentCycle() async {
    try {
      final db = await DBHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cycles',
        orderBy: 'start_date DESC',
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return CycleModel.fromSQLite(maps.first);
      }
    } catch (e) {
      debugPrint('Erreur de lecture du cycle SQLite : $e');
    }

    try {
      final settings = await _settingsRepository.getSettings();
      return CycleService.buildCycleFromSettings(settings);
    } catch (e) {
      debugPrint('Erreur de lecture du cycle à partir des paramètres : $e');
    }

    return null;
  }

  @override
  Future<List<DayInfoModel>> getMonthDays(DateTime month) async {
    final cycle = await getCurrentCycle();
    if (cycle == null) {
      return [];
    }

    final daysInMonth = CycleDateUtils.daysInMonth(month.year, month.month);
    final today = CycleDateUtils.dateOnly(DateTime.now());

    return List.generate(daysInMonth, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final dayInCycle = CycleUtils.cycleDay(
        date: date,
        lastPeriodStart: cycle.startDate,
        cycleDuration: cycle.cycleDuration,
      );
      final safeDayInCycle = dayInCycle == 0 ? 1 : dayInCycle;

      return DayInfoModel(
        date: date,
        dayInCycle: safeDayInCycle,
        phase: CycleUtils.phaseForDay(
          day: safeDayInCycle,
          cycleDuration: cycle.cycleDuration,
          periodDuration: cycle.expectedPeriodDuration,
        ),
        fertilityLevel: CycleUtils.fertilityForDay(
          day: safeDayInCycle,
          cycleDuration: cycle.cycleDuration,
        ),
        basalTemperature: null,
        temperatureDelta: null,
        isPredicted: date.isAfter(today),
      );
    });
  }

  @override
  Future<double?> getTodayBasalTemperature() async {
    try {
      final todayLog = await _dailyLogRepository.getLogForDate(DateTime.now());
      return todayLog?.basalTemperature;
    } catch (e) {
      debugPrint('Erreur lors de la lecture de la température du jour : $e');
      return null;
    }
  }

  @override
  Future<void> saveCycle(CycleModel cycle) async {
    try {
      final db = await DBHelper.instance.database;
      await db.insert(
        'cycles',
        cycle.toSQLiteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ Cycle sauvegardé en local (SQLite).');

      final user = _auth.currentUser;
      if (user == null) {
        debugPrint(
            'Aucun utilisateur Firebase connecté. Cycle sauvegardé localement.');
        return;
      }

      await _firestore.collection('users').doc(user.uid).set(
        {
          'last_active': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cycles')
          .doc(cycle.id)
          .set(cycle.toFirestoreMap());

      await db.update(
        'cycles',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [cycle.id],
      );
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du cycle : $e');
    }
  }

  CycleModel _defaultCycleForFallback() {
    final now = DateTime.now();
    return CycleModel(
      id: 'fallback-${now.millisecondsSinceEpoch}',
      startDate: now,
      endDate: null,
      predictedOvulation: now.add(const Duration(days: 14)),
      predictedFertilityStart: now.add(const Duration(days: 9)),
      predictedFertilityEnd: now.add(const Duration(days: 15)),
      cycleDuration: CycleUtils.defaultCycleDuration,
      expectedPeriodDuration: CycleUtils.defaultPeriodDuration,
      regularity: 'Régulier',
      lastUpdated: now,
      isSynced: 1,
    );
  }

  @override
  Future<void> syncLocalToFirebase() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final db = await DBHelper.instance.database;
      final List<Map<String, dynamic>> unSyncedMaps =
          await db.query('cycles', where: 'is_synced = ?', whereArgs: [0]);
      for (var map in unSyncedMaps) {
        final localCycle = CycleModel.fromSQLite(map);
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cycles')
            .doc(localCycle.id)
            .set(localCycle.toFirestoreMap());
        await db.update('cycles', {'is_synced': 1},
            where: 'id = ?', whereArgs: [localCycle.id]);
      }
    } catch (e) {
      debugPrint("Erreur sync : $e");
    }
  }
}
