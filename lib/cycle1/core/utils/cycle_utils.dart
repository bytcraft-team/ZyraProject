import 'dart:math' as math;
import 'package:zyra/cycle1/data/models/daily_log_model.dart';
import '../../data/models/cycle_model.dart';
import '../../data/models/day_info_model.dart'; // Contient CyclePhase, FertilityLevel
import 'date_utils.dart';

/// Utilitaires de calcul du cycle menstruel
class CycleUtils {
  CycleUtils._(); // Classe non instanciable

  // ─────────────────────────────────────────────────────────────
  // Constantes par défaut
  // ─────────────────────────────────────────────────────────────

  static const int defaultCycleDuration = 28;
  static const int defaultPeriodDuration = 5;
  static const double defaultCycleTemperature = 36.5;

  // Durées standard des phases (en jours)
  static const int phasePeriodDays    = 5;  // Règles
  static const int phaseFertileDays   = 5;  // Fertile
  static const int phaseOvulationDay  = 1;  // Ovulation
  static const int phaseLutealDays    = 14; // Lutéale

  // ─────────────────────────────────────────────────────────────
  // Calcul du jour dans le cycle
  // ─────────────────────────────────────────────────────────────

  /// Calcule le jour actuel dans le cycle
  static int currentCycleDay({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    return cycleDay(
      date: DateTime.now(),
      lastPeriodStart: lastPeriodStart,
      cycleDuration: cycleDuration,
    ).clamp(1, cycleDuration);
  }

  /// Calcule le jour dans le cycle pour une date donnée
  static int cycleDay({
    required DateTime date,
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    if (cycleDuration <= 0) return 1;
    final diff = CycleDateUtils.dateOnly(date)
        .difference(CycleDateUtils.dateOnly(lastPeriodStart))
        .inDays;
    return (diff % cycleDuration) + 1;
  }

  // ─────────────────────────────────────────────────────────────
  // Phase du cycle
  // ─────────────────────────────────────────────────────────────

  /// Détermine la phase du cycle pour un jour donné (Logique corrigée)
  static CyclePhase phaseForDay({
    required int day,
    int cycleDuration = defaultCycleDuration,
    int periodDuration = defaultPeriodDuration,
  }) {
    if (day < 1 || day > cycleDuration) return CyclePhase.luteal;

    final ovulationDay = _ovulationDay(cycleDuration);

    // 1. Phase des règles
    if (day <= periodDuration) return CyclePhase.rules;

    // 2. Jour de l'ovulation
    if (day == ovulationDay) return CyclePhase.ovulation;

    // 3. Phase lutéale (post-ovulation)
    if (day > ovulationDay) return CyclePhase.luteal;

    // 4. Phase folliculaire et fenêtre fertile avant l'ovulation
    return CyclePhase.fertile;
  }

  /// Jour d'ovulation estimé (14 jours avant les prochaines règles)
  static int _ovulationDay(int cycleDuration) {
    return cycleDuration - 14;
  }

  /// Phase actuelle du cycle
  static CyclePhase currentPhase({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
    int periodDuration = defaultPeriodDuration,
  }) {
    final day = currentCycleDay(
      lastPeriodStart: lastPeriodStart,
      cycleDuration: cycleDuration,
    );
    return phaseForDay(
      day: day,
      cycleDuration: cycleDuration,
      periodDuration: periodDuration,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Prochaines règles
  // ─────────────────────────────────────────────────────────────

  /// Date des prochaines règles
  static DateTime nextPeriodDate({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    final today = CycleDateUtils.dateOnly(DateTime.now());
    final start = CycleDateUtils.dateOnly(lastPeriodStart);
    final daysSince = today.difference(start).inDays;
    final cyclesElapsed = (daysSince / cycleDuration).floor();
    var next = start.add(Duration(days: (cyclesElapsed + 1) * cycleDuration));

    if (next.isBefore(today)) {
      next = next.add(Duration(days: cycleDuration));
    }
    return next;
  }

  /// Jours restants avant les prochaines règles
  static int daysUntilNextPeriod({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    final next = nextPeriodDate(
      lastPeriodStart: lastPeriodStart,
      cycleDuration: cycleDuration,
    );
    return CycleDateUtils.daysUntil(next);
  }

  // ─────────────────────────────────────────────────────────────
  // Fenêtre fertile
  // ─────────────────────────────────────────────────────────────

  /// Date de début de la fenêtre fertile
  static DateTime fertileWindowStart({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    final ovDay = _ovulationDay(cycleDuration);
    return CycleDateUtils.dateOnly(lastPeriodStart).add(Duration(days: ovDay - 6));
  }

  /// Date de fin de la fenêtre fertile (incluant le jour d'ovulation)
  static DateTime fertileWindowEnd({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    return ovulationDate(
      lastPeriodStart: lastPeriodStart,
      cycleDuration: cycleDuration,
    );
  }

  /// Date d'ovulation estimée (Synchronisée sur ovDay)
  static DateTime ovulationDate({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    final ovDay = _ovulationDay(cycleDuration);
    return CycleDateUtils.dateOnly(lastPeriodStart).add(Duration(days: ovDay - 1));
  }

  /// Vrai si une date est dans la fenêtre fertile
  static bool isFertileDay({
    required DateTime date,
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    final day = cycleDay(
      date: date,
      lastPeriodStart: lastPeriodStart,
      cycleDuration: cycleDuration,
    );
    final ovulationDay = _ovulationDay(cycleDuration);
    final fertileStart = ovulationDay - 5;
    return day >= fertileStart && day <= ovulationDay;
  }

  // ─────────────────────────────────────────────────────────────
  // Fertilité
  // ─────────────────────────────────────────────────────────────

  /// Niveau de fertilité pour un jour du cycle
  static FertilityLevel fertilityForDay({
    required int day,
    int cycleDuration = defaultCycleDuration,
  }) {
    final phase = phaseForDay(day: day, cycleDuration: cycleDuration);
    switch (phase) {
      case CyclePhase.rules:
        return FertilityLevel.low;
      case CyclePhase.fertile:
        final ovDay = _ovulationDay(cycleDuration);
        final fertileStart = ovDay - 5;
        if (day < fertileStart) return FertilityLevel.low;
        if (day < ovDay - 1) return FertilityLevel.medium;
        return FertilityLevel.high;
      case CyclePhase.ovulation:
        return FertilityLevel.veryHigh;
      case CyclePhase.luteal:
        return FertilityLevel.low;
    }
  }

  /// Fertilité actuelle
  static FertilityLevel currentFertility({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    final day = currentCycleDay(
      lastPeriodStart: lastPeriodStart,
      cycleDuration: cycleDuration,
    );
    return fertilityForDay(day: day, cycleDuration: cycleDuration);
  }

  // ─────────────────────────────────────────────────────────────
  // Progression du cycle
  // ─────────────────────────────────────────────────────────────

  /// Pourcentage de progression dans le cycle [0.0 – 1.0]
  static double cycleProgress({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    final day = currentCycleDay(
      lastPeriodStart: lastPeriodStart,
      cycleDuration: cycleDuration,
    );
    return (day / cycleDuration).clamp(0.0, 1.0);
  }

  /// Progression en pourcentage arrondi
  static int cycleProgressPercent({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
  }) {
    return (cycleProgress(
              lastPeriodStart: lastPeriodStart,
              cycleDuration: cycleDuration,
            ) *
            100)
        .round();
  }

  // ─────────────────────────────────────────────────────────────
  // Régularité du cycle
  // ─────────────────────────────────────────────────────────────

  /// Écart-type des longueurs de cycles pour l'analyse statistique interne
  static double _getCycleStdDev(List<int> cycleLengths) {
    if (cycleLengths.length < 2) return 0.0;
    final mean = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance = cycleLengths
            .map((l) => (l - mean) * (l - mean))
            .reduce((a, b) => a + b) /
        cycleLengths.length;
    return math.sqrt(variance);
  }

  /// Durée moyenne du cycle
  static double averageCycleDuration(List<int> cycleLengths) {
    if (cycleLengths.isEmpty) return defaultCycleDuration.toDouble();
    return cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
  }

  /// Durée minimale du cycle
  static int minCycleDuration(List<int> cycleLengths) {
    if (cycleLengths.isEmpty) return defaultCycleDuration;
    return cycleLengths.reduce((a, b) => a < b ? a : b);
  }

  /// Durée maximale du cycle
  static int maxCycleDuration(List<int> cycleLengths) {
    if (cycleLengths.isEmpty) return defaultCycleDuration;
    return cycleLengths.reduce((a, b) => a > b ? a : b);
  }

  // Temperature tracking removed from utils

  // ─────────────────────────────────────────────────────────────
  // Génération des DailyLogModel pour le calendrier
  // ─────────────────────────────────────────────────────────────

  /// Génère les infos de chaque jour d'un mois sous forme de DailyLogModel
  static List<DailyLogModel> generateMonthInfo({
    required DateTime month,
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
    int periodDuration = defaultPeriodDuration,
    Map<String, double>? recordedTemperatures,
  }) {
    final days = CycleDateUtils.allDaysInMonth(month);

    return days.map((date) {
      final key = CycleDateUtils.storageKey(date);
      final temp = recordedTemperatures?[key];

      return DailyLogModel(
        date: date,
        hasData: temp != null,
        symptoms: const [],
        moods: const [],
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────
  // Résumé et Diagnostics textuels
  // ─────────────────────────────────────────────────────────────

  /// Texte de la phase courante
  static String phaseSummary({
    required CyclePhase phase,
    required int day,
    required int cycleDuration,
  }) {
    final daysUntilOv = _ovulationDay(cycleDuration) - day;
    switch (phase) {
      case CyclePhase.rules:
        return 'Phase menstruelle · Jour $day';
      case CyclePhase.fertile:
        return daysUntilOv > 0
            ? 'Fenêtre fertile · Ovulation dans $daysUntilOv j'
            : 'Fenêtre fertile · Ovulation demain';
      case CyclePhase.ovulation:
        return '🔴 Jour de l\'ovulation';
      case CyclePhase.luteal:
        return 'Phase lutéale · Repos';
    }
  }

  /// Label complet de régularité aligné sur les nouveaux modèles textuels
  static String regularityLabel(List<int> cycleLengths) {
    if (cycleLengths.length < 2) return 'Régulier';
    final stdDev = _getCycleStdDev(cycleLengths);
    
    if (stdDev < 2.0) {
      return 'Régulier';
    } else if (stdDev >= 2.0 && stdDev <= 4.5) {
      return 'Légèrement irrégulier';
    } else {
      return 'Très irrégulier';
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Validation
  // ─────────────────────────────────────────────────────────────

  static bool isValidCycleDuration(int days) => days >= 21 && days <= 45;
  static bool isValidPeriodDuration(int days) => days >= 1 && days <= 10;
  // Basal temperature validation removed

  // ─────────────────────────────────────────────────────────────
  // Prédictions futures
  // ─────────────────────────────────────────────────────────────

  /// Génère les prochaines dates de règles sur N cycles
  static List<DateTime> upcomingPeriods({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
    int count = 3,
  }) {
    final result = <DateTime>[];
    var next = nextPeriodDate(
      lastPeriodStart: lastPeriodStart,
      cycleDuration: cycleDuration,
    );
    for (int i = 0; i < count; i++) {
      result.add(next);
      next = next.add(Duration(days: cycleDuration));
    }
    return result;
  }

  /// Génère les prochaines dates d'ovulation sur N cycles
  static List<DateTime> upcomingOvulations({
    required DateTime lastPeriodStart,
    int cycleDuration = defaultCycleDuration,
    int count = 3,
  }) {
    final ovDay = _ovulationDay(cycleDuration);
    final result = <DateTime>[];
    var base = CycleDateUtils.dateOnly(lastPeriodStart);

    for (int i = 0; i < count + 1; i++) {
      final ov = base.add(Duration(days: ovDay - 1));
      if (ov.isAfter(DateTime.now())) {
        result.add(ov);
        if (result.length >= count) break;
      }
      base = base.add(Duration(days: cycleDuration));
    }
    return result;
  }
}