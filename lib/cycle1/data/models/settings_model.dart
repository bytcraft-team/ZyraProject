import 'package:flutter/material.dart';

// ─── Régularité ───────────────────────────────────────────────
enum CycleRegularity { regular, slightlyIrregular, veryIrregular }

extension CycleRegularityExt on CycleRegularity {
  String get label {
    switch (this) {
      case CycleRegularity.regular:
        return 'Régulier';
      case CycleRegularity.slightlyIrregular:
        return 'Légèrement irrégulier';
      case CycleRegularity.veryIrregular:
        return 'Très irrégulier';
    }
  }

  String get description {
    switch (this) {
      case CycleRegularity.regular:
        return 'Mes règles arrivent à peu près\nà la même date chaque mois';
      case CycleRegularity.slightlyIrregular:
        return 'Variation de quelques jours\nd\'un cycle à l\'autre';
      case CycleRegularity.veryIrregular:
        return 'Mes cycles varient beaucoup\nchaque mois';
    }
  }

  String get emoji {
    switch (this) {
      case CycleRegularity.regular:
        return '🕐';
      case CycleRegularity.slightlyIrregular:
        return '🌊';
      case CycleRegularity.veryIrregular:
        return '🌀';
    }
  }
}

// ─── Objectif ─────────────────────────────────────────────────
enum UserGoal {
  simpleTracking,
  conception,
  naturalContraception,
  hormonalHealth,
}

extension UserGoalExt on UserGoal {
  String get label {
    switch (this) {
      case UserGoal.simpleTracking:
        return 'Suivi simple';
      case UserGoal.conception:
        return 'Conception';
      case UserGoal.naturalContraception:
        return 'Contraception naturelle';
      case UserGoal.hormonalHealth:
        return 'Santé hormonale';
    }
  }

  String get description {
    switch (this) {
      case UserGoal.simpleTracking:
        return 'Suivre mes cycles\nsans objectif précis';
      case UserGoal.conception:
        return 'Identifier mes jours\nfertiles pour concevoir';
      case UserGoal.naturalContraception:
        return 'Éviter une grossesse\nnaturellement';
      case UserGoal.hormonalHealth:
        return 'Comprendre mes hormones\net mon bien-être';
    }
  }

  String get emoji {
    switch (this) {
      case UserGoal.simpleTracking:
        return '📊';
      case UserGoal.conception:
        return '👶';
      case UserGoal.naturalContraception:
        return '🌿';
      case UserGoal.hormonalHealth:
        return '💊';
    }
  }
}

// ─── Paramètres de notification ───────────────────────────────
class NotificationSettings {
  final bool dailyJournalReminder;
  final TimeOfDay? dailyReminderTime;
  final bool periodInTwoDaysAlert;
  final bool fertileWindowAlert;
  final bool ovulationAlert;
  final bool periodEndAlert;

  const NotificationSettings({
    this.dailyJournalReminder = true,
    this.dailyReminderTime,
    this.periodInTwoDaysAlert = true,
    this.fertileWindowAlert = true,
    this.ovulationAlert = true,
    this.periodEndAlert = false,
  });

  NotificationSettings copyWith({
    bool? dailyJournalReminder,
    TimeOfDay? dailyReminderTime,
    bool? periodInTwoDaysAlert,
    bool? fertileWindowAlert,
    bool? ovulationAlert,
    bool? periodEndAlert,
  }) {
    return NotificationSettings(
      dailyJournalReminder: dailyJournalReminder ?? this.dailyJournalReminder,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      periodInTwoDaysAlert: periodInTwoDaysAlert ?? this.periodInTwoDaysAlert,
      fertileWindowAlert: fertileWindowAlert ?? this.fertileWindowAlert,
      ovulationAlert: ovulationAlert ?? this.ovulationAlert,
      periodEndAlert: periodEndAlert ?? this.periodEndAlert,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyJournalReminder': dailyJournalReminder,
      'dailyReminderTime': dailyReminderTime == null
          ? null
          : dailyReminderTime!.hour * 60 + dailyReminderTime!.minute,
      'periodInTwoDaysAlert': periodInTwoDaysAlert,
      'fertileWindowAlert': fertileWindowAlert,
      'ovulationAlert': ovulationAlert,
      'periodEndAlert': periodEndAlert,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    final rawMinutes = map['dailyReminderTime'];
    final int? minutes = rawMinutes is int ? rawMinutes : null;
    return NotificationSettings(
      dailyJournalReminder: map['dailyJournalReminder'] as bool? ?? true,
      dailyReminderTime: minutes != null
          ? TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60)
          : null,
      periodInTwoDaysAlert: map['periodInTwoDaysAlert'] as bool? ?? true,
      fertileWindowAlert: map['fertileWindowAlert'] as bool? ?? true,
      ovulationAlert: map['ovulationAlert'] as bool? ?? true,
      periodEndAlert: map['periodEndAlert'] as bool? ?? false,
    );
  }
}

// ─── Historique d'un cycle ────────────────────────────────────
class CycleHistoryEntry {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? duration;
  final int? periodDuration;
  final String
  regularity; // Mis à jour de bool à String pour s'aligner sur CycleModel

  const CycleHistoryEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    this.duration,
    this.periodDuration,
    this.regularity = 'Régulier',
  });

  String get startLabel {
    const months = [
      '',
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    return '${startDate.day} ${months[startDate.month]} ${startDate.year}';
  }

  String get endLabel {
    if (endDate == null) return 'En cours';
    const months = [
      '',
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    return '${endDate!.day} ${months[endDate!.month]} ${endDate!.year}';
  }

  CycleHistoryEntry copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? duration,
    int? periodDuration,
    String? regularity,
  }) {
    return CycleHistoryEntry(
      id: id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      periodDuration: periodDuration ?? this.periodDuration,
      regularity: regularity ?? this.regularity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'duration': duration,
      'periodDuration': periodDuration,
      'regularity': regularity,
    };
  }

  factory CycleHistoryEntry.fromMap(Map<String, dynamic> map) {
    return CycleHistoryEntry(
      id: map['id'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      duration: map['duration'] as int?,
      periodDuration: map['periodDuration'] as int?,
      regularity: map['regularity'] as String? ?? 'Régulier',
    );
  }
}

// ─── Paramètres globaux ───────────────────────────────────────
class CycleSettings {
  final bool onboardingCompleted;
  final bool hasCompletedCycleQuestions;
  final DateTime? lastPeriodStart;
  final int cycleDuration;
  final int periodDuration;
  final CycleRegularity regularity;
  final UserGoal goal;
  final NotificationSettings notifications;
  final List<CycleHistoryEntry> history;
  final String userName;

  const CycleSettings({
    this.onboardingCompleted = false,
    this.hasCompletedCycleQuestions = false,
    this.lastPeriodStart,
    this.cycleDuration = 28,
    this.periodDuration = 5,
    this.regularity = CycleRegularity.regular,
    this.goal = UserGoal.simpleTracking,
    this.notifications = const NotificationSettings(),
    this.history = const [],
    this.userName = '',
  });

  CycleSettings copyWith({
    bool? onboardingCompleted,
    bool? hasCompletedCycleQuestions,
    DateTime? lastPeriodStart,
    int? cycleDuration,
    int? periodDuration,
    CycleRegularity? regularity,
    UserGoal? goal,
    NotificationSettings? notifications,
    List<CycleHistoryEntry>? history,
    String? userName,
  }) {
    return CycleSettings(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      hasCompletedCycleQuestions:
          hasCompletedCycleQuestions ?? this.hasCompletedCycleQuestions,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      cycleDuration: cycleDuration ?? this.cycleDuration,
      periodDuration: periodDuration ?? this.periodDuration,
      regularity: regularity ?? this.regularity,
      goal: goal ?? this.goal,
      notifications: notifications ?? this.notifications,
      history: history ?? this.history,
      userName: userName ?? this.userName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'onboardingCompleted': onboardingCompleted,
      'hasCompletedCycleQuestions': hasCompletedCycleQuestions,
      'lastPeriodStart': lastPeriodStart?.toIso8601String(),
      'cycleDuration': cycleDuration,
      'periodDuration': periodDuration,
      'regularity': regularity.index,
      'goal': goal.index,
      'notifications': notifications.toMap(),
      'history': history.map((entry) => entry.toMap()).toList(),
      'userName': userName,
    };
  }

  factory CycleSettings.fromMap(Map<String, dynamic> map) {
    return CycleSettings(
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      hasCompletedCycleQuestions:
          map['hasCompletedCycleQuestions'] as bool? ?? false,
      lastPeriodStart: map['lastPeriodStart'] != null
          ? DateTime.parse(map['lastPeriodStart'] as String)
          : null,
      cycleDuration: map['cycleDuration'] as int? ?? 28,
      periodDuration: map['periodDuration'] as int? ?? 5,
      regularity: CycleRegularity.values[map['regularity'] as int? ?? 0],
      goal: UserGoal.values[map['goal'] as int? ?? 0],
      notifications: map['notifications'] != null
          ? NotificationSettings.fromMap(
              Map<String, dynamic>.from(map['notifications'] as Map),
            )
          : const NotificationSettings(),
      history: map['history'] != null
          ? List<Map<String, dynamic>>.from(
              map['history'] as List,
            ).map(CycleHistoryEntry.fromMap).toList()
          : const [],
      userName: map['userName'] as String? ?? '',
    );
  }
}
