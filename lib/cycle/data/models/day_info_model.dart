import 'cycle_model.dart';

enum FertilityLevel { low, medium, high, veryHigh }

extension FertilityLevelExtension on FertilityLevel {
  String get label {
    switch (this) {
      case FertilityLevel.low:
        return 'Basse';
      case FertilityLevel.medium:
        return 'Moyenne';
      case FertilityLevel.high:
        return 'Haute';
      case FertilityLevel.veryHigh:
        return 'Très haute';
    }
  }
}

class DayInfoModel {
  final DateTime date;
  final int dayInCycle;
  final CyclePhase phase;
  final FertilityLevel fertilityLevel;
  final double? basalTemperature;
  final double? temperatureDelta;
  final bool isPredicted;

  const DayInfoModel({
    required this.date,
    required this.dayInCycle,
    required this.phase,
    required this.fertilityLevel,
    this.basalTemperature,
    this.temperatureDelta,
    this.isPredicted = false,
  });
}