import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/services/cycle_service.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/db_helper.dart';
import '../../core/utils/date_utils.dart';
import '../models/cycle_model.dart';
import '../models/daily_log_model.dart';
import '../models/day_info_model.dart';
// removed unused import
import '../models/user_model.dart';
import 'daily_log_repository.dart';
import 'settings_repository.dart';

abstract class CycleRepository {
  Future<UserModel> getUser();
  Future<CycleModel?> getCurrentCycle();
  Future<List<DayInfoModel>> getMonthDays(DateTime month);
  Future<void> saveCycle(CycleModel cycle);
  Future<void> syncLocalToFirebase();
  Stream<DateTime> get onDailyLogChanged;
}

class CycleRepositoryImpl implements CycleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SettingsRepository _settingsRepository = SettingsRepositoryImpl();
  final DailyLogRepository _dailyLogRepository = DailyLogRepositoryImpl();

  @override
  Stream<DateTime> get onDailyLogChanged => _dailyLogRepository.onLogChanged;

  @override
  Future<UserModel> getUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          return UserModel.fromMap({
            // Prefer Firestore fields, fallback to FirebaseAuth displayName, avoid hardcoded names
            'firstName': data['first_name'] ?? user.displayName ?? '',
            'lastName': data['last_name'] ?? '',
            'profileImageUrl': data['profile_image_url'] ?? user.photoURL,
            'hasUnreadNotifications': data['has_unread_notifications'] ?? false,
            'unreadNotificationCount': data['unread_notification_count'] ?? 0,
          });
        }
        // If Firestore doc missing, still return a user built from FirebaseAuth
        return UserModel(
          firstName: user.displayName,
          lastName: null,
          profileImageUrl: user.photoURL,
          hasUnreadNotifications: false,
          unreadNotificationCount: 0,
        );
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
    // Générer la liste de jours basée sur la logique actuelle
    final rawDays = List.generate(daysInMonth, (index) {
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
        isPredicted: date.isAfter(today),
      );
    });

    return rawDays;
  }

  // getTodayBasalTemperature removed (temperature tracking disabled)

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

  // _defaultCycleForFallback removed (not used)

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
