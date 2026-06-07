import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'cycle_model.dart';
import 'day_info_model.dart'; // Contient CyclePhase et FertilityLevel

// ─── Statistiques du cycle ─────────────────────────────────────
class CycleStats {
  final double avgCycleDuration;
  final double avgPeriodDuration;
  final int avgOvulationDay;
  final int cyclesAnalyzed;

  const CycleStats({
    required this.avgCycleDuration,
    required this.avgPeriodDuration,
    required this.avgOvulationDay,
    required this.cyclesAnalyzed,
  });

  String get avgCycleLabel => '${avgCycleDuration.toStringAsFixed(0)}j';
  String get avgPeriodLabel => '${avgPeriodDuration.toStringAsFixed(0)}j';
  String get avgOvulationLabel => 'Jour $avgOvulationDay';
}

// ─── Conseil contextuel ────────────────────────────────────────
class PhaseAdvice {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final List<String> tips;

  const PhaseAdvice({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.tips,
  });

  static PhaseAdvice forPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.rules:
        return const PhaseAdvice(
          title: 'Phase menstruelle — Prends soin de toi',
          body: 'Ton corps travaille dur. Écoute-le et accorde-toi du repos.',
          icon: Icons.self_improvement_rounded,
          color: AppColors.phaseRules,
          tips: [
            '🌡️ Bouillotte sur le ventre pour les crampes',
            '🍫 Le magnésium réduit les douleurs',
            '🧘 Yoga doux et étirements',
            '💧 Bien s\'hydrater — 2L d\'eau par jour',
            '😴 Sommeil : 8h minimum recommandées',
          ],
        );

      case CyclePhase.fertile:
        return const PhaseAdvice(
          title: 'Fenêtre fertile — Haute énergie',
          body: 'Tu es dans ta fenêtre fertile. Ton énergie et ta créativité sont à leur maximum.',
          icon: Icons.bolt_rounded,
          color: AppColors.phaseFertile,
          tips: [
            '🏃 Profite de ton énergie pour le sport',
            '💑 Fenêtre de conception ouverte',
            '🥗 Alimentation riche en folates',
            '🌸 Œstrogènes élevés = bonne humeur',
            '🔬 Observer la glaire cervicale',
          ],
        );

      case CyclePhase.ovulation:
        return const PhaseAdvice(
          title: 'Ovulation — Fertilité maximale',
          body: 'L\'ovule est libéré. Ta fertilité est à son pic aujourd\'hui.',
          icon: Icons.favorite_rounded,
          color: AppColors.phaseOvulation,
          tips: [
            '🔴 Fertilité maximale aujourd\'hui et demain',
            '🌡️ La température basale monte légèrement',
            '💧 La glaire devient filante comme du blanc d\'œuf',
            '⚡ Énergie et libido à leur maximum',
            '📅 Marquer ce jour pour les prochains cycles',
          ],
        );

      case CyclePhase.luteal:
        return const PhaseAdvice(
          title: 'Phase lutéale — Douceur & nutrition',
          body: 'La progestérone monte. Le SPM peut apparaître en fin de phase.',
          icon: Icons.spa_rounded,
          color: AppColors.phaseLuteal,
          tips: [
            '🥦 Légumes verts pour réduire le SPM',
            '🍌 Banane riche en B6 contre l\'irritabilité',
            '🧘 Méditation pour gérer le stress',
            '☕ Réduire la caféine et le sel',
            '🛁 Bains chauds relaxants recommandés',
          ],
        );
    }
  }
}

// ─── Modèle de calendrier mensuel ─────────────────────────────
class CalendarMonth {
  final DateTime month;
  final List<CalendarDay> days;
  final int firstWeekdayOffset; // 0=lundi ... 6=dimanche

  const CalendarMonth({
    required this.month,
    required this.days,
    required this.firstWeekdayOffset,
  });

  int get weeksCount {
    final total = firstWeekdayOffset + days.length;
    return (total / 7).ceil();
  }
}

// ─── Cellule calendrier ────────────────────────────────────────
class CalendarDay {
  final DateTime date;
  final int dayInCycle;
  final CyclePhase phase;
  final FertilityLevel fertilityLevel;
  final bool isPredicted;
  final bool hasLoggedData;
  final bool isToday;

  const CalendarDay({
    required this.date,
    required this.dayInCycle,
    required this.phase,
    required this.fertilityLevel,
    required this.isPredicted,
    required this.hasLoggedData,
    required this.isToday,
  });

  // Utilise l'extension sur CyclePhase si disponible, sinon fallback sur AppColors
  Color get phaseColor {
    try {
      return (phase as dynamic).activeColor as Color;
    } catch (_) {
      switch (phase) {
        case CyclePhase.rules: return AppColors.phaseRules;
        case CyclePhase.fertile: return AppColors.phaseFertile;
        case CyclePhase.ovulation: return AppColors.phaseOvulation;
        case CyclePhase.luteal: return AppColors.phaseLuteal;
      }
    }
  }

  Color get phaseSoftColor {
    try {
      return (phase as dynamic).softColor as Color;
    } catch (_) {
      switch (phase) {
        case CyclePhase.rules: return AppColors.phaseRulesSoft;
        case CyclePhase.fertile: return AppColors.phaseFertileSoft;
        case CyclePhase.ovulation: return AppColors.phaseOvulationSoft;
        case CyclePhase.luteal: return AppColors.phaseLutealSoft;
      }
    }
  }

  bool get isCurrentMonth => true;
}

// ─── Segment de la timeline ────────────────────────────────────
class TimelineSegment {
  final CyclePhase phase;
  final int startDay;
  final int endDay;
  final double widthFraction; // [0.0 – 1.0]

  const TimelineSegment({
    required this.phase,
    required this.startDay,
    required this.endDay,
    required this.widthFraction,
  });

  int get durationDays => endDay - startDay + 1;
}