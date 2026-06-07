import 'dart:math' as math;

import '../../data/models/calendar_model.dart';
import '../../data/models/cycle_model.dart';
import '../../data/models/daily_log_model.dart';
import '../../data/models/settings_model.dart';
import '../utils/cycle_utils.dart';
import '../utils/date_utils.dart';

class CycleService {
  CycleService._();

  static CycleModel? buildCycleFromSettings(CycleSettings settings) {
    if (!settings.onboardingCompleted || settings.lastPeriodStart == null) {
      return null;
    }

    final startDate = CycleDateUtils.dateOnly(settings.lastPeriodStart!);
    final predictedOvulation = CycleUtils.ovulationDate(
      lastPeriodStart: startDate,
      cycleDuration: settings.cycleDuration,
    );

    return CycleModel(
      id: 'settings-cycle-${startDate.millisecondsSinceEpoch}',
      startDate: startDate,
      endDate: null,
      predictedOvulation: predictedOvulation,
      predictedFertilityStart: CycleUtils.fertileWindowStart(
        lastPeriodStart: startDate,
        cycleDuration: settings.cycleDuration,
      ),
      predictedFertilityEnd: CycleUtils.fertileWindowEnd(
        lastPeriodStart: startDate,
        cycleDuration: settings.cycleDuration,
      ),
      cycleDuration: settings.cycleDuration,
      expectedPeriodDuration: settings.periodDuration,
      regularity: settings.regularity.label,
      lastUpdated: DateTime.now(),
      isSynced: 1,
    );
  }

  static CycleStats buildCycleStats({
    required CycleModel? cycle,
    required List<CycleHistoryEntry> history,
  }) {
    final cycleLengths = history
        .map((entry) => entry.duration ?? cycle?.cycleDuration)
        .whereType<int>()
        .where((duration) => duration > 0)
        .toList();

    final periodLengths = history
        .map((entry) => entry.periodDuration ?? cycle?.expectedPeriodDuration)
        .whereType<int>()
        .where((duration) => duration > 0)
        .toList();

    if (cycle != null) {
      if (cycleLengths.isEmpty) {
        cycleLengths.add(cycle.cycleDuration);
      }
      if (periodLengths.isEmpty) {
        periodLengths.add(cycle.expectedPeriodDuration);
      }
    }

    return CycleStats(
      avgCycleDuration: CycleUtils.averageCycleDuration(cycleLengths),
      avgPeriodDuration: CycleUtils.averageCycleDuration(periodLengths),
      avgOvulationDay:
          cycle != null ? math.max(1, cycle.cycleDuration - 14) : 14,
      cyclesAnalyzed: math.max(1, cycleLengths.length),
    );
  }

  static CalendarMonth buildCalendarMonth({
    required DateTime month,
    required CycleModel cycle,
    Set<String> loggedDayKeys = const {},
  }) {
    final today = CycleDateUtils.dateOnly(DateTime.now());
    final daysInMonth = CycleDateUtils.daysInMonth(month.year, month.month);
    final offset = CycleDateUtils.firstWeekdayOffset(month);

    final days = List.generate(daysInMonth, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final rawDayInCycle = CycleUtils.cycleDay(
        date: date,
        lastPeriodStart: cycle.startDate,
        cycleDuration: cycle.cycleDuration,
      );
      final dayInCycle = rawDayInCycle == 0 ? 1 : rawDayInCycle;
      final phase = CycleUtils.phaseForDay(
        day: dayInCycle,
        cycleDuration: cycle.cycleDuration,
        periodDuration: cycle.expectedPeriodDuration,
      );
      final fertility = CycleUtils.fertilityForDay(
        day: dayInCycle,
        cycleDuration: cycle.cycleDuration,
      );

      return CalendarDay(
        date: date,
        dayInCycle: dayInCycle,
        phase: phase,
        fertilityLevel: fertility,
        isPredicted: date.isAfter(today),
        hasLoggedData: loggedDayKeys.contains(CycleDateUtils.storageKey(date)),
        isToday: CycleDateUtils.isSameDay(date, today),
        // basalTemperature removed
      );
    });

    return CalendarMonth(
      month: month,
      days: days,
      firstWeekdayOffset: offset,
    );
  }

  static List<TimelineSegment> buildTimelineSegments(CycleModel cycle) {
    final segments = <TimelineSegment>[];
    CyclePhase? currentPhase;
    int startDay = 1;

    for (int day = 1; day <= cycle.cycleDuration; day++) {
      final phaseAtDay = CycleUtils.phaseForDay(
        day: day,
        cycleDuration: cycle.cycleDuration,
        periodDuration: cycle.expectedPeriodDuration,
      );

      if (currentPhase == null) {
        currentPhase = phaseAtDay;
        startDay = day;
        continue;
      }

      if (phaseAtDay != currentPhase) {
        final duration = day - startDay;
        segments.add(TimelineSegment(
          phase: currentPhase,
          startDay: startDay,
          endDay: day - 1,
          widthFraction: duration / cycle.cycleDuration,
        ));
        currentPhase = phaseAtDay;
        startDay = day;
      }

      if (day == cycle.cycleDuration) {
        final duration = day - startDay + 1;
        segments.add(TimelineSegment(
          phase: currentPhase,
          startDay: startDay,
          endDay: day,
          widthFraction: duration / cycle.cycleDuration,
        ));
      }
    }

    return segments;
  }

  static CalendarDay buildDayDetail(
    DateTime date,
    CycleModel cycle, {
    bool hasLoggedData = false,
  }) {
    final today = CycleDateUtils.dateOnly(DateTime.now());
    final rawDayInCycle = CycleUtils.cycleDay(
      date: date,
      lastPeriodStart: cycle.startDate,
      cycleDuration: cycle.cycleDuration,
    );
    final dayInCycle = rawDayInCycle == 0 ? 1 : rawDayInCycle;
    final phase = CycleUtils.phaseForDay(
      day: dayInCycle,
      cycleDuration: cycle.cycleDuration,
      periodDuration: cycle.expectedPeriodDuration,
    );
    final fertility = CycleUtils.fertilityForDay(
      day: dayInCycle,
      cycleDuration: cycle.cycleDuration,
    );

    return CalendarDay(
      date: date,
      dayInCycle: dayInCycle,
      phase: phase,
      fertilityLevel: fertility,
      isPredicted: date.isAfter(today),
      hasLoggedData: hasLoggedData,
      isToday: CycleDateUtils.isSameDay(date, today),
      // basalTemperature removed
    );
  }
}
