import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ─── Flow Intensity ───────────────────────────────────────────
enum FlowIntensity { none, light, medium, heavy, veryHeavy }

extension FlowIntensityExt on FlowIntensity {
  String get label {
    switch (this) {
      case FlowIntensity.none:       return 'Aucun';
      case FlowIntensity.light:      return 'Léger';
      case FlowIntensity.medium:     return 'Moyen';
      case FlowIntensity.heavy:      return 'Abondant';
      case FlowIntensity.veryHeavy:  return 'Très\nabondant';
    }
  }

  Color get color {
    switch (this) {
      case FlowIntensity.none:       return Colors.grey.shade300;
      case FlowIntensity.light:      return const Color(0xFFF8BBD0);
      case FlowIntensity.medium:     return const Color(0xFFE91E8C);
      case FlowIntensity.heavy:      return const Color(0xFFC2185B);
      case FlowIntensity.veryHeavy:  return const Color(0xFF880E4F);
    }
  }
}

// ─── Symptom ──────────────────────────────────────────────────
enum SymptomType {
  cramps, headache, breastTenderness, fatigue, nausea,
  bloating, backPain, dizziness, acne, insomnia, appetite, anxiety,
  hotFlashes, jointPain, skinChanges, hairLoss,
}

extension SymptomTypeExt on SymptomType {
  String get label {
    switch (this) {
      case SymptomType.cramps:           return 'Crampes';
      case SymptomType.headache:         return 'Maux de\ntête';
      case SymptomType.breastTenderness: return 'Seins\nsensibles';
      case SymptomType.fatigue:          return 'Fatigue';
      case SymptomType.nausea:           return 'Nausées';
      case SymptomType.bloating:         return 'Ballonne-\nments';
      case SymptomType.backPain:         return 'Douleurs\nlombaires';
      case SymptomType.dizziness:        return 'Vertiges';
      case SymptomType.acne:             return 'Acné';
      case SymptomType.insomnia:         return 'Insomnie';
      case SymptomType.appetite:         return 'Appétit\naugmenté';
      case SymptomType.anxiety:          return 'Anxiété';
      case SymptomType.hotFlashes:       return 'Bouffées\nde chaleur';
      case SymptomType.jointPain:        return 'Douleurs\narticulaires';
      case SymptomType.skinChanges:      return 'Peau\nsèche';
      case SymptomType.hairLoss:         return 'Chute\nde cheveux';
    }
  }

  String get emoji {
    switch (this) {
      case SymptomType.cramps:           return '🤕';
      case SymptomType.headache:         return '🤯';
      case SymptomType.breastTenderness: return '💗';
      case SymptomType.fatigue:          return '😴';
      case SymptomType.nausea:           return '🤢';
      case SymptomType.bloating:         return '🫃';
      case SymptomType.backPain:         return '🦴';
      case SymptomType.dizziness:        return '💫';
      case SymptomType.acne:             return '😣';
      case SymptomType.insomnia:         return '🌙';
      case SymptomType.appetite:         return '🍽️';
      case SymptomType.anxiety:          return '😰';
      case SymptomType.hotFlashes:       return '🔥';
      case SymptomType.jointPain:        return '🦵';
      case SymptomType.skinChanges:      return '🧴';
      case SymptomType.hairLoss:         return '💇';
    }
  }

  static List<SymptomType> get defaults => [
    SymptomType.cramps, SymptomType.headache, SymptomType.breastTenderness,
    SymptomType.fatigue, SymptomType.nausea, SymptomType.bloating,
    SymptomType.backPain, SymptomType.dizziness, SymptomType.acne,
    SymptomType.insomnia, SymptomType.appetite, SymptomType.anxiety,
  ];

  static List<SymptomType> get extras => [
    SymptomType.hotFlashes, SymptomType.jointPain,
    SymptomType.skinChanges, SymptomType.hairLoss,
  ];
}

// ─── Symptom Entry ────────────────────────────────────────────
class SymptomEntry {
  final SymptomType type;
  final int intensity; // 1, 2, 3

  const SymptomEntry({required this.type, required this.intensity});

  SymptomEntry copyWith({SymptomType? type, int? intensity}) {
    return SymptomEntry(
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'intensity': intensity,
    };
  }

  factory SymptomEntry.fromMap(Map<String, dynamic> map) {
    return SymptomEntry(
      type: SymptomType.values.byName(map['type'] as String),
      intensity: map['intensity'] as int,
    );
  }
}

// ─── Mood ─────────────────────────────────────────────────────
enum MoodType { sad, irritable, neutral, good, great }

extension MoodTypeExt on MoodType {
  String get label {
    switch (this) {
      case MoodType.sad:       return 'Triste';
      case MoodType.irritable: return 'Irritable';
      case MoodType.neutral:   return 'Neutre';
      case MoodType.good:      return 'Bien';
      case MoodType.great:     return 'Super';
    }
  }

  String get emoji {
    switch (this) {
      case MoodType.sad:       return '😢';
      case MoodType.irritable: return '😤';
      case MoodType.neutral:   return '😐';
      case MoodType.good:      return '🙂';
      case MoodType.great:     return '😄';
    }
  }

  Color get activeColor => AppColors.pink;
  Color get activeBg    => AppColors.pinkSoft;
}

// ─── Cervical Mucus ───────────────────────────────────────────
enum CervicalMucusType { none, dry, creamy, watery, eggWhite }

extension CervicalMucusTypeExt on CervicalMucusType {
  String get label {
    switch (this) {
      case CervicalMucusType.none:      return 'Aucun';
      case CervicalMucusType.dry:       return 'Sec';
      case CervicalMucusType.creamy:    return 'Crémeux';
      case CervicalMucusType.watery:    return 'Aqueux';
      case CervicalMucusType.eggWhite:  return 'Filant';
    }
  }

  String get emoji {
    switch (this) {
      case CervicalMucusType.none:      return '⭕';
      case CervicalMucusType.dry:       return '🏜️';
      case CervicalMucusType.creamy:    return '🥛';
      case CervicalMucusType.watery:    return '💧';
      case CervicalMucusType.eggWhite:  return '🥚';
    }
  }

  Color get color {
    switch (this) {
      case CervicalMucusType.none:      return Colors.grey;
      case CervicalMucusType.dry:       return const Color(0xFFFF8A65);
      case CervicalMucusType.creamy:    return const Color(0xFFFFF176);
      case CervicalMucusType.watery:    return const Color(0xFF64B5F6);
      case CervicalMucusType.eggWhite:  return const Color(0xFF81C784);
    }
  }

  String get fertilityHint {
    switch (this) {
      case CervicalMucusType.none:      return 'Pas d\'observation';
      case CervicalMucusType.dry:       return 'Fertilité très faible';
      case CervicalMucusType.creamy:    return 'Fertilité faible à modérée';
      case CervicalMucusType.watery:    return 'Fertilité modérée à élevée';
      case CervicalMucusType.eggWhite:  return 'Fertilité maximale — Ovulation probable';
    }
  }
}



// ─── Daily Log (modèle principal sérialisé) ───────────────────
class DailyLogModel {
  final DateTime date;
  final String? status; // ex: 'menstruation','fertile','ovulation','luteal'
  final FlowIntensity? flowIntensity;
  final List<SymptomEntry> symptoms;
  final List<MoodType> moods;
  final CervicalMucusType? cervicalMucus;
  final List<String> notes;
  final bool hasData;

  const DailyLogModel({
    required this.date,
    this.status,
    this.flowIntensity,
    this.symptoms = const [],
    this.moods = const [],
    this.cervicalMucus,
    this.notes = const [],
    this.hasData = false,
  });

  DailyLogModel copyWith({
    DateTime? date,
    String? status,
    FlowIntensity? flowIntensity,
    List<SymptomEntry>? symptoms,
    List<MoodType>? moods,
    CervicalMucusType? cervicalMucus,
    List<String>? notes,
    bool? hasData,
  }) {
    return DailyLogModel(
      date: date ?? this.date,
      status: status ?? this.status,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      symptoms: symptoms ?? this.symptoms,
      moods: moods ?? this.moods,
      cervicalMucus: cervicalMucus ?? this.cervicalMucus,
      notes: notes ?? this.notes,
      hasData: hasData ?? this.hasData,
    );
  }

  // Sérialisation vers une Map (Base de données / JSON)
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'status': status,
      'flowIntensity': flowIntensity?.name,
      'symptoms': symptoms.map((x) => x.toMap()).toList(),
      'moods': moods.map((x) => x.name).toList(),
      'cervicalMucus': cervicalMucus?.name,
      'notes': notes,
      'hasData': hasData,
    };
  }

  // Désérialisation depuis une Map
  factory DailyLogModel.fromMap(Map<String, dynamic> map) {
    return DailyLogModel(
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String?,
      flowIntensity: map['flowIntensity'] != null
          ? FlowIntensity.values.byName(map['flowIntensity'] as String)
          : null,
      symptoms: map['symptoms'] != null
          ? List<SymptomEntry>.from(
              (map['symptoms'] as List).map(
                (x) => SymptomEntry.fromMap(x as Map<String, dynamic>),
              ),
            )
          : const [],
      moods: map['moods'] != null
          ? List<MoodType>.from(
              (map['moods'] as List).map(
                (x) => MoodType.values.byName(x as String),
              ),
            )
          : const [],
      cervicalMucus: map['cervicalMucus'] != null
          ? CervicalMucusType.values.byName(map['cervicalMucus'] as String)
          : null,
      notes: map['notes'] != null
          ? List<String>.from(map['notes'] as List)
          : const [],
      hasData: map['hasData'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory DailyLogModel.fromJson(String source) =>
      DailyLogModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}