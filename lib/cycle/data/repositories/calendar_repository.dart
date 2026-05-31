import '../models/calendar_model.dart';
import '../models/cycle_model.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class CalendarRepository {
  Future<CalendarMonth> getCalendarMonth(DateTime month);
  Future<CycleStats> getCycleStats();
  Future<List<TimelineSegment>> getTimelineSegments(int cycleDuration);
  Future<CalendarDay> getDayDetail(DateTime date);
}

class CalendarRepositoryImpl implements CalendarRepository {
  // Données de simulation nettoyées des heures pour éviter les décalages de calculs
  final DateTime _lastPeriodStart = CycleDateUtils.dateOnly(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  ).subtract(const Duration(days: 13));

  static const int _cycleDuration = 28;
  static const int _periodDuration = 5;

  @override
  Future<CalendarMonth> getCalendarMonth(DateTime month) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final now = CycleDateUtils.dateOnly(DateTime.now());
    final daysInMonth = CycleDateUtils.daysInMonth(month.year, month.month);
    final offset = CycleDateUtils.firstWeekdayOffset(month);

    // Jours simulés avec données enregistrées (jours passés avant aujourd'hui)
    final loggedDays = <String>{};
    for (int i = 1; i <= daysInMonth; i++) {
      final d = DateTime(month.year, month.month, i);
      if (d.isBefore(now) && d.day % 3 == 0) {
        loggedDays.add(CycleDateUtils.storageKey(d));
      }
    }

    final days = List.generate(daysInMonth, (i) {
      final date = DateTime(month.year, month.month, i + 1);
      final dayInCycle = CycleUtils.cycleDay(
        date: date,
        lastPeriodStart: _lastPeriodStart,
        cycleDuration: _cycleDuration,
      );
      final phase = CycleUtils.phaseForDay(
        day: dayInCycle,
        cycleDuration: _cycleDuration,
        periodDuration: _periodDuration,
      );
      final fertility = CycleUtils.fertilityForDay(
        day: dayInCycle,
        cycleDuration: _cycleDuration,
      );
      final isPredicted = CycleDateUtils.dateOnly(date).isAfter(now);
      final isToday = CycleDateUtils.isSameDay(date, now);
      final hasData = loggedDays.contains(CycleDateUtils.storageKey(date));

      return CalendarDay(
        date: date,
        dayInCycle: dayInCycle,
        phase: phase,
        fertilityLevel: fertility,
        isPredicted: isPredicted,
        hasLoggedData: hasData,
        isToday: isToday,
        basalTemperature: hasData ? 36.5 + (dayInCycle * 0.02) : null,
      );
    });

    return CalendarMonth(
      month: month,
      days: days,
      firstWeekdayOffset: offset,
    );
  }

  @override
  Future<CycleStats> getCycleStats() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const CycleStats(
      avgCycleDuration: 28,
      avgPeriodDuration: 5,
      avgOvulationDay: 14,
      cyclesAnalyzed: 3,
    );
  }

  @override
  Future<List<TimelineSegment>> getTimelineSegments(int cycleDuration) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final segments = <TimelineSegment>[];
    CyclePhase? currentTrackingPhase;
    int startDay = 1;

    // Détection et construction 100% dynamique des segments de phases
    for (int day = 1; day <= cycleDuration; day++) {
      final phaseAtDay = CycleUtils.phaseForDay(
        day: day,
        cycleDuration: cycleDuration,
        periodDuration: _periodDuration,
      );

      if (currentTrackingPhase == null) {
        currentTrackingPhase = phaseAtDay;
        startDay = day;
      } else if (phaseAtDay != currentTrackingPhase || day == cycleDuration) {
        // Gérer la fin du cycle sur le dernier jour
        final actualEnd = (day == cycleDuration && phaseAtDay == currentTrackingPhase) 
            ? day 
            : day - 1;
            
        final duration = actualEnd - startDay + 1;
        segments.add(TimelineSegment(
          phase: currentTrackingPhase,
          startDay: startDay,
          endDay: actualEnd,
          widthFraction: duration / cycleDuration,
        ));

        // Initialiser le segment suivant si non arrivé au bout
        if (day == cycleDuration && phaseAtDay != currentTrackingPhase) {
          segments.add(TimelineSegment(
            phase: phaseAtDay,
            startDay: day,
            endDay: day,
            widthFraction: 1 / cycleDuration,
          ));
        }

        currentTrackingPhase = phaseAtDay;
        startDay = day;
      }
    }
    return segments;
  }

  @override
  Future<CalendarDay> getDayDetail(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = CycleDateUtils.dateOnly(DateTime.now());
    
    final dayInCycle = CycleUtils.cycleDay(
      date: date,
      lastPeriodStart: _lastPeriodStart,
      cycleDuration: _cycleDuration,
    );
    
    // Corrigé : Ajout du paramètre nommé requis 'day:'
    final phase = CycleUtils.phaseForDay(
      day: dayInCycle,
      cycleDuration: _cycleDuration,
      periodDuration: _periodDuration,
    );
    
    final fertility = CycleUtils.fertilityForDay(
      day: dayInCycle,
      cycleDuration: _cycleDuration,
    );
    
    return CalendarDay(
      date: date,
      dayInCycle: dayInCycle,
      phase: phase,
      fertilityLevel: fertility,
      isPredicted: CycleDateUtils.dateOnly(date).isAfter(now),
      hasLoggedData: false,
      isToday: CycleDateUtils.isSameDay(date, now),
    );
  }
}