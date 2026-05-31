import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/utils/db_helper.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/date_utils.dart';
import '../models/cycle_model.dart';
import '../models/day_info_model.dart';
import '../models/user_model.dart';

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
      if (maps.isEmpty) return null;
      return CycleModel.fromSQLite(maps.first);
    } catch (e) {
      debugPrint('Erreur de lecture du cycle SQLite : $e');
      return null;
    }
  }

  @override
  Future<List<DayInfoModel>> getMonthDays(DateTime month) async {
    final currentCycle = await getCurrentCycle();
    final cycle = currentCycle ?? _defaultCycleForFallback();
    final daysInMonth = CycleDateUtils.daysInMonth(month.year, month.month);
    final today = CycleDateUtils.dateOnly(DateTime.now());

    return List.generate(daysInMonth, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final rawDayInCycle = CycleDateUtils.daysBetween(cycle.startDate, date) + 1;
      final dayInCycle = rawDayInCycle > 0 ? rawDayInCycle : 1;
      
      return DayInfoModel(
        date: date,
        dayInCycle: dayInCycle,
        phase: CycleUtils.phaseForDay(day: dayInCycle, cycleDuration: cycle.cycleDuration, periodDuration: cycle.expectedPeriodDuration),
        fertilityLevel: CycleUtils.fertilityForDay(day: dayInCycle, cycleDuration: cycle.cycleDuration),
        basalTemperature: date.isAfter(today) ? null : 36.5 + (dayInCycle * 0.01),
        temperatureDelta: null,
        isPredicted: date.isAfter(today),
      );
    });
  }

  @override
  Future<double?> getTodayBasalTemperature() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return 36.8;
  }

  @override
  Future<void> saveCycle(CycleModel cycle) async {
    try {
      final db = await DBHelper.instance.database;

      // 1. Sauvegarde locale SQLite
      await db.insert('cycles', cycle.toSQLiteMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint('✅ Cycle sauvegardé en local (SQLite).');

      // 2. Connexion ou Inscription automatique de ton compte réel
      var user = _auth.currentUser;
      if (user == null) {
        debugPrint('Inscription/Connexion automatique avec hajarettabti2003@gmail.com...');
        try {
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: 'hajarettabti2003@gmail.com',
            password: 'HajarZyra2026',
          );
          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            final userCredential = await _auth.signInWithEmailAndPassword(
              email: 'hajarettabti2003@gmail.com',
              password: 'HajarZyra2026',
            );
            user = userCredential.user;
          } else {
            rethrow;
          }
        }
        debugPrint("🔓 Connecté avec succès ! UID: ${user?.uid}");
      }

      // 3. Envoi direct à Cloud Firestore sous ton UID personnalisé
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'first_name': 'Hajar',
          'last_name': '',
          'last_active': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _firestore.collection('users').doc(user.uid).collection('cycles').doc(cycle.id).set(cycle.toFirestoreMap());
        
        await db.update('cycles', {'is_synced': 1}, where: 'id = ?', whereArgs: [cycle.id]);
        debugPrint('🚀 [FIREBASE SUCCÈS] Les données sont en ligne pour ton compte !');
      }
    } catch (e) {
      debugPrint('⚠️ Échec Firebase (Exécution fallback sync) : $e');
      await syncLocalToFirebase();
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
      final List<Map<String, dynamic>> unSyncedMaps = await db.query('cycles', where: 'is_synced = ?', whereArgs: [0]);
      for (var map in unSyncedMaps) {
        final localCycle = CycleModel.fromSQLite(map);
        await _firestore.collection('users').doc(user.uid).collection('cycles').doc(localCycle.id).set(localCycle.toFirestoreMap());
        await db.update('cycles', {'is_synced': 1}, where: 'id = ?', whereArgs: [localCycle.id]);
      }
    } catch (e) {
      debugPrint("Erreur sync : $e");
    }
  }
}