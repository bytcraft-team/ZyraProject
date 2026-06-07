import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/calendar_model.dart';
import '../models/cycle_model.dart';
import '../models/day_info_model.dart';
import '../models/daily_log_model.dart';
import '../../core/services/cycle_service.dart';
import '../../core/utils/date_utils.dart';
import 'daily_log_repository.dart';
import 'settings_repository.dart';

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
    // Construire le mois via le service puis surcharger les phases à partir
    // des daily logs si un champ `status` est présent.
    final built = CycleService.buildCalendarMonth(
      month: month,
      cycle: cycle,
      loggedDayKeys: loggedKeys,
    );

    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month, CycleDateUtils.daysInMonth(month.year, month.month));
      final logs = await _dailyLogRepository.getLogsForRange(start, end);

      final mapByDate = <String, DailyLogModel>{};
      for (final l in logs) {
        final key = l.date.toIso8601String().split('T')[0];
        mapByDate[key] = l;
      }

      final overriddenDays = built.days.map((d) {
        final key = d.date.toIso8601String().split('T')[0];
        final log = mapByDate[key];
        if (log != null && log.status != null && log.status!.isNotEmpty) {
          CyclePhase? mapped;
          switch (log.status!.toLowerCase()) {
            case 'menstruation':
            case 'rules':
              mapped = CyclePhase.rules;
              break;
            case 'fertile':
              mapped = CyclePhase.fertile;
              break;
            case 'ovulation':
              mapped = CyclePhase.ovulation;
              break;
            case 'luteal':
              mapped = CyclePhase.luteal;
              break;
            default:
              mapped = null;
          }

          if (mapped != null) {
            return CalendarDay(
              date: d.date,
              dayInCycle: d.dayInCycle,
              phase: mapped,
              fertilityLevel: d.fertilityLevel,
              isPredicted: false,
              hasLoggedData: true,
              isToday: d.isToday,
            );
          }
        }
        return d;
      }).toList();

      return CalendarMonth(month: built.month, days: overriddenDays, firstWeekdayOffset: built.firstWeekdayOffset);
    } catch (e) {
      debugPrint('Erreur surchargement daily logs pour calendar month: $e');
      return built;
    }
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

    try {
      final log = await _dailyLogRepository.getLogForDate(date);
      final base = CycleService.buildDayDetail(
        date,
        cycle,
        hasLoggedData: log != null,
      );

      if (log != null && log.status != null && log.status!.isNotEmpty) {
        switch (log.status!.toLowerCase()) {
          case 'menstruation':
          case 'rules':
            return CalendarDay(
              date: base.date,
              dayInCycle: base.dayInCycle,
              phase: CyclePhase.rules,
              fertilityLevel: base.fertilityLevel,
              isPredicted: false,
              hasLoggedData: true,
              isToday: base.isToday,
            );
          case 'fertile':
            return CalendarDay(
              date: base.date,
              dayInCycle: base.dayInCycle,
              phase: CyclePhase.fertile,
              fertilityLevel: base.fertilityLevel,
              isPredicted: false,
              hasLoggedData: true,
              isToday: base.isToday,
            );
          case 'ovulation':
            return CalendarDay(
              date: base.date,
              dayInCycle: base.dayInCycle,
              phase: CyclePhase.ovulation,
              fertilityLevel: base.fertilityLevel,
              isPredicted: false,
              hasLoggedData: true,
              isToday: base.isToday,
            );
          case 'luteal':
            return CalendarDay(
              date: base.date,
              dayInCycle: base.dayInCycle,
              phase: CyclePhase.luteal,
              fertilityLevel: base.fertilityLevel,
              isPredicted: false,
              hasLoggedData: true,
              isToday: base.isToday,
            );
          default:
            return base;
        }
      }

      return base;
    } catch (e) {
      debugPrint('Erreur getDayDetail override from daily logs: $e');
      return CycleService.buildDayDetail(
        date,
        cycle,
        hasLoggedData: false,
      );
    }
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
