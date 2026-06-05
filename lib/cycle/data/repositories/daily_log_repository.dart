import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/date_utils.dart';
import '../models/daily_log_model.dart';

abstract class DailyLogRepository {
  Future<DailyLogModel?> getLogForDate(DateTime date);
  Future<void> saveLog(DailyLogModel log);
  Future<Map<DateTime, bool>> getWeekHasData(DateTime weekStart);
}

class DailyLogRepositoryImpl implements DailyLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, DailyLogModel> _cache = {};

  CollectionReference<Map<String, dynamic>> _dailyLogCollection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_logs');
  }

  String _dayKey(DateTime date) => CycleDateUtils.storageKey(date);

  @override
  Future<DailyLogModel?> getLogForDate(DateTime date) async {
    final key = _dayKey(date);
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint('🔒 DailyLogRepository: aucun utilisateur Firebase connecté, lecture locale seulement.');
      return _cache[key];
    }

    try {
      final doc = await _dailyLogCollection(user.uid).doc(key).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final model = DailyLogModel.fromMap(Map<String, dynamic>.from(doc.data()!));
      _cache[key] = model;
      return model;
    } catch (e, stack) {
      debugPrint('Erreur DailyLogRepository getLogForDate: $e');
      debugPrint('$stack');
      return _cache[key];
    }
  }

  @override
  Future<void> saveLog(DailyLogModel log) async {
    final key = _dayKey(log.date);
    final savedLog = log.copyWith(hasData: true);
    _cache[key] = savedLog;

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('🔒 DailyLogRepository: aucun utilisateur Firebase connecté, sauvegarde locale conservée.');
      return;
    }

    try {
      await _dailyLogCollection(user.uid).doc(key).set(savedLog.toMap());
      debugPrint('✅ DailyLog sauvegardé sur Firestore pour $key');
    } catch (e, stack) {
      debugPrint('Erreur DailyLogRepository saveLog: $e');
      debugPrint('$stack');
    }
  }

  @override
  Future<Map<DateTime, bool>> getWeekHasData(DateTime weekStart) async {
    final cleanStart = CycleDateUtils.dateOnly(weekStart);
    final result = <DateTime, bool>{};

    for (int i = 0; i < 7; i++) {
      final currentDay = cleanStart.add(Duration(days: i));
      result[currentDay] = false;
    }

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('🔒 DailyLogRepository: aucun utilisateur Firebase connecté, lecture locale seulement.');
      for (int i = 0; i < 7; i++) {
        final currentDay = cleanStart.add(Duration(days: i));
        final key = _dayKey(currentDay);
        result[currentDay] = _cache.containsKey(key);
      }
      return result;
    }

    try {
      final start = cleanStart.toIso8601String();
      final end = cleanStart.add(const Duration(days: 6)).toIso8601String();
      final snapshot = await _dailyLogCollection(user.uid)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final date = DateTime.parse(data['date'] as String);
        final key = _dayKey(date);
        if (result.containsKey(date)) {
          result[date] = true;
        }
        _cache[key] = DailyLogModel.fromMap(data);
      }
    } catch (e, stack) {
      debugPrint('Erreur DailyLogRepository getWeekHasData: $e');
      debugPrint('$stack');
      for (int i = 0; i < 7; i++) {
        final currentDay = cleanStart.add(Duration(days: i));
        final key = _dayKey(currentDay);
        result[currentDay] = _cache.containsKey(key);
      }
    }

    return result;
  }
}