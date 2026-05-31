import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

enum CyclePhase { rules, fertile, ovulation, luteal }

extension CyclePhaseExtension on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.rules:
        return 'Règles';
      case CyclePhase.fertile:
        return 'Fertile';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Lutéale';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.rules:
        return 'Phase menstruelle';
      case CyclePhase.fertile:
        return 'Fenêtre fertile';
      case CyclePhase.ovulation:
        return 'Haute fertilité';
      case CyclePhase.luteal:
        return 'Phase de repos';
    }
  }

  String get detailedDescription {
    switch (this) {
      case CyclePhase.rules:
        return 'C\'est la période de tes règles. Ton corps élimine la muqueuse utérine. '
            'Tu peux ressentir des crampes, de la fatigue ou des maux de tête. '
            'Prends soin de toi et repose-toi suffisamment.';
      case CyclePhase.fertile:
        return 'Ta fenêtre fertile est ouverte. Les spermatozoïdes peuvent survivre '
            'jusqu\'à 5 jours dans ton corps. C\'est une période propice à la conception '
            'si tu souhaites tomber enceinte.';
      case CyclePhase.ovulation:
        return 'C\'est le moment de l\'ovulation ! Ton ovaire libère un ovule qui est '
            'prêt à être fécondé pendant 12 à 24 heures. Tu peux ressentir une légère '
            'douleur au bas-ventre. Ta fertilité est à son maximum.';
      case CyclePhase.luteal:
        return 'Après l\'ovulation, ton corps se prépare pour un éventuel début de '
            'grossesse. Si la fécondation n\'a pas eu lieu, les niveaux hormonaux '
            'baissent et tes règles arrivent. Tu peux ressentir des symptômes prémenstruels.';
    }
  }

  Color get activeColor {
    switch (this) {
      case CyclePhase.rules:
        return AppColors.phaseRules;
      case CyclePhase.fertile:
        return AppColors.phaseFertile;
      case CyclePhase.ovulation:
        return AppColors.phaseOvulation;
      case CyclePhase.luteal:
        return AppColors.phaseLuteal;
    }
  }

  Color get softColor {
    switch (this) {
      case CyclePhase.rules:
        return AppColors.phaseRulesSoft;
      case CyclePhase.fertile:
        return AppColors.phaseFertileSoft;
      case CyclePhase.ovulation:
        return AppColors.phaseOvulationSoft;
      case CyclePhase.luteal:
        return AppColors.phaseLutealSoft;
    }
  }

  IconData get icon {
    switch (this) {
      case CyclePhase.rules:
        return Icons.water_drop_rounded;
      case CyclePhase.fertile:
        return Icons.spa_rounded;
      case CyclePhase.ovulation:
        return Icons.favorite_rounded;
      case CyclePhase.luteal:
        return Icons.nights_stay_rounded;
    }
  }
}

class CycleModel {
  final String id; // Requis pour Firebase et SQLite
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime predictedOvulation;
  final DateTime predictedFertilityStart;
  final DateTime predictedFertilityEnd;
  final int cycleDuration;
  final int expectedPeriodDuration;
  final String regularity;
  final DateTime lastUpdated;
  final int isSynced; // 0 = non synchronisé, 1 = synchronisé

  const CycleModel({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.predictedOvulation,
    required this.predictedFertilityStart,
    required this.predictedFertilityEnd,
    required this.cycleDuration,
    required this.expectedPeriodDuration,
    required this.regularity,
    required this.lastUpdated,
    this.isSynced = 0,
  });

  // --- GETTERS DYNAMIQUES POUR L'UI ---

  // Calcule le numéro du jour actuel dans le cycle (J1, J2...)
  int get currentDay {
    final today = DateTime.now();
    final difference = today.difference(startDate).inDays + 1;
    // Sécurité au cas où on dépasse la durée théorique du cycle avant d'en déclarer un nouveau
    return difference > 0 ? difference : 1;
  }

  // Pourcentage de progression pour ta barre de progression ou ton CustomPainter
  double get progressPercent {
    double percent = currentDay / cycleDuration;
    return percent > 1.0 ? 1.0 : percent;
  }

  // Calcule le nombre de jours restants avant les prochaines règles
  int get daysUntilNextPeriod {
    final nextPeriod = startDate.add(Duration(days: cycleDuration));
    final diff = nextPeriod.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  // Retourne la date prévue des prochaines règles
  DateTime get nextPeriodDate => startDate.add(Duration(days: cycleDuration));

  // Détermine dynamiquement la phase pour n'importe quelle date donnée
  CyclePhase getPhaseForDate(DateTime targetDate) {
    final date = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final ovul = DateTime(predictedOvulation.year, predictedOvulation.month, predictedOvulation.day);
    final fertStart = DateTime(predictedFertilityStart.year, predictedFertilityStart.month, predictedFertilityStart.day);
    final fertEnd = DateTime(predictedFertilityEnd.year, predictedFertilityEnd.month, predictedFertilityEnd.day);

    // 1. Phase des Règles
    final endOfPeriod = start.add(Duration(days: expectedPeriodDuration - 1));
    if (date.isAtSameMomentAs(start) || (date.isAfter(start) && date.isBefore(endOfPeriod.add(const Duration(days: 1))))) {
      return CyclePhase.rules;
    }

    // 2. Jour de l'Ovulation
    if (date.isAtSameMomentAs(ovul)) {
      return CyclePhase.ovulation;
    }

    // 3. Fenêtre Fertile (Autour de l'ovulation)
    if ((date.isAfter(fertStart.subtract(const Duration(days: 1))) && date.isBefore(fertEnd.add(const Duration(days: 1))))) {
      return CyclePhase.fertile;
    }

    // 4. Phase Lutéale (Après l'ovulation et avant les prochaines règles)
    if (date.isAfter(ovul)) {
      return CyclePhase.luteal;
    }

    // Par défaut, si on est entre les règles et la fertilité : Phase Folliculaire
    // Tu peux utiliser la couleur fertile adoucie ou lutéale selon ton UI de repos.
    return CyclePhase.luteal; 
  }

  // Récupère la phase actuelle à l'instant T
  CyclePhase get currentPhase => getPhaseForDate(DateTime.now());

  // --- MAPPINGS POUR BASES DE DONNÉES ---

  // Extraction depuis SQLite
  factory CycleModel.fromSQLite(Map<String, dynamic> map) {
    return CycleModel(
      id: map['id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      predictedOvulation: DateTime.parse(map['predicted_ovulation']),
      predictedFertilityStart: DateTime.parse(map['predicted_fertility_start']),
      predictedFertilityEnd: DateTime.parse(map['predicted_fertility_end']),
      cycleDuration: map['cycle_duration'],
      expectedPeriodDuration: map['period_duration'],
      regularity: map['regularity'],
      lastUpdated: DateTime.parse(map['last_updated']),
      isSynced: map['is_synced'],
    );
  }

  bool get isRegular {
    final value = regularity.trim().toLowerCase();
    return value == 'regular' || value == 'régulier' || value == 'true' || value == '1';
  }

  int get duration => cycleDuration;

  // Conversion pour insertion SQLite
  Map<String, dynamic> toSQLiteMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'predicted_ovulation': predictedOvulation.toIso8601String().split('T')[0],
      'predicted_fertility_start': predictedFertilityStart.toIso8601String().split('T')[0],
      'predicted_fertility_end': predictedFertilityEnd.toIso8601String().split('T')[0],
      'cycle_duration': cycleDuration,
      'period_duration': expectedPeriodDuration,
      'regularity': regularity,
      'last_updated': lastUpdated.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  // Conversion pour Firebase Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'predicted_ovulation': Timestamp.fromDate(predictedOvulation),
      'predicted_fertility_start': Timestamp.fromDate(predictedFertilityStart),
      'predicted_fertility_end': Timestamp.fromDate(predictedFertilityEnd),
      'cycle_duration': cycleDuration,
      'period_duration': expectedPeriodDuration,
      'regularity': regularity,
      'last_updated': Timestamp.fromDate(lastUpdated),
    };
  }
}