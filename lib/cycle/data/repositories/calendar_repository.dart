import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/calendar_model.dart';
import '../models/cycle_model.dart';
import '../models/day_info_model.dart';
import '../../core/services/cycle_service.dart';
import '../../core/utils/date_utils.dart';
import '../repositories/daily_log_repository.dart';
import '../repositories/settings_repository.dart';

abstract class CalendarRepository {
  Future<CalendarMonth> getCalendarMonth(DateTime month);
  Future<CycleStats> getCycleStats();
  Future<List<TimelineSegment>> getTimelineSegments(int cycleDuration);
  Future<CalendarDay> getDayDetail(DateTime date);
}

class CalendarRepositoryImpl implements CalendarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SettingsRepository _settingsRepository = SettingsRepositoryImpl();
  final DailyLogRepository _dailyLogRepository = DailyLogRepositoryImpl();

  @override
  Future<CalendarMonth> getCalendarMonth(DateTime month) async {
    final cycle = await _getCurrentCycle();
    final offset = CycleDateUtils.firstWeekdayOffset(month);
    if (cycle == null) {
      return CalendarMonth(month: month, days: [], firstWeekdayOffset: offset);
    }

    final loggedKeys = await _loadLoggedKeysForMonth(month);
    return CycleService.buildCalendarMonth(
      month: month,
      cycle: cycle,
      loggedDayKeys: loggedKeys,
    );
  }

  @override
  Future<CycleStats> getCycleStats() async {
    final cycle = await _getCurrentCycle();
    final settings = await _settingsRepository.getSettings();
    return CycleService.buildCycleStats(
      cycle: cycle,
      history: settings.history,
    );
  }

  @override
  Future<List<TimelineSegment>> getTimelineSegments(int cycleDuration) async {
    final cycle = await _getCurrentCycle();
    if (cycle == null) {
      return CycleService.buildTimelineSegments(
        CycleModel(
          id: 'default',
          startDate: DateTime.now(),
          endDate: null,
          predictedOvulation: DateTime.now().add(const Duration(days: 14)),
          predictedFertilityStart: DateTime.now().add(const Duration(days: 9)),
          predictedFertilityEnd: DateTime.now().add(const Duration(days: 15)),
          cycleDuration: cycleDuration,
          expectedPeriodDuration: 5,
          regularity: 'Régulier',
          lastUpdated: DateTime.now(),
        ),
      );
    }
    return CycleService.buildTimelineSegments(cycle);
  }

  @override
  Future<CalendarDay> getDayDetail(DateTime date) async {
    final cycle = await _getCurrentCycle();
    final now = CycleDateUtils.dateOnly(DateTime.now());
    if (cycle == null) {
      return CalendarDay(
        date: date,
        dayInCycle: 0,
        phase: CyclePhase.luteal,
        fertilityLevel: FertilityLevel.low,
        isPredicted: date.isAfter(now),
        hasLoggedData: false,
        isToday: CycleDateUtils.isSameDay(date, now),
      );
    }

    final loggedKeys =
        await _loadLoggedKeysForMonth(DateTime(date.year, date.month));
    final hasLoggedData = loggedKeys.contains(CycleDateUtils.storageKey(date));
    return CycleService.buildDayDetail(
      date,
      cycle,
      hasLoggedData: hasLoggedData,
    );
  }

  Future<CycleModel?> _getCurrentCycle() async {
    try {
      final settings = await _settingsRepository.getSettings();
      return CycleService.buildCycleFromSettings(settings);
    } catch (e) {
      debugPrint('Erreur lecture cycle pour calendar: $e');
      return null;
    }
  }

  Future<Set<String>> _loadLoggedKeysForMonth(DateTime month) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(
      month.year,
      month.month,
      CycleDateUtils.daysInMonth(month.year, month.month),
      23,
      59,
      59,
    );

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_logs')
          .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('date', isLessThanOrEqualTo: end.toIso8601String())
          .get();

      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      debugPrint('Erreur lecture logs mensuels: $e');
      return {};
    }
  }
}
