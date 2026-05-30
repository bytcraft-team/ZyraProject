enum UserProfileType { pregnancy, cycle }

class OnboardingData {
  final UserProfileType profileType;
  final int? pregnancyWeek;
  final DateTime? lastMenstrualPeriodDate;
  final bool? firstPregnancy;
  final bool? weeklyUpdates;
  final bool? nutritionTips;
  final int? averageCycleLength;
  final int? periodDuration;
  final DateTime? lastPeriodDate;
  final bool? cycleRegular;
  final bool? remindersEnabled;

  OnboardingData({
    required this.profileType,
    this.pregnancyWeek,
    this.lastMenstrualPeriodDate,
    this.firstPregnancy,
    this.weeklyUpdates,
    this.nutritionTips,
    this.averageCycleLength,
    this.periodDuration,
    this.lastPeriodDate,
    this.cycleRegular,
    this.remindersEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'profileType': profileType.name,
      'pregnancyWeek': pregnancyWeek,
      'lastMenstrualPeriodDate': lastMenstrualPeriodDate?.toIso8601String(),
      'firstPregnancy': firstPregnancy,
      'weeklyUpdates': weeklyUpdates,
      'nutritionTips': nutritionTips,
      'averageCycleLength': averageCycleLength,
      'periodDuration': periodDuration,
      'lastPeriodDate': lastPeriodDate?.toIso8601String(),
      'cycleRegular': cycleRegular,
      'remindersEnabled': remindersEnabled,
    };
  }

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      profileType: UserProfileType.values.firstWhere(
        (item) => item.name == json['profileType'],
        orElse: () => UserProfileType.cycle,
      ),
      pregnancyWeek: json['pregnancyWeek'] as int?,
      lastMenstrualPeriodDate: json['lastMenstrualPeriodDate'] != null
          ? DateTime.parse(json['lastMenstrualPeriodDate'] as String)
          : null,
      firstPregnancy: json['firstPregnancy'] as bool?,
      weeklyUpdates: json['weeklyUpdates'] as bool?,
      nutritionTips: json['nutritionTips'] as bool?,
      averageCycleLength: json['averageCycleLength'] as int?,
      periodDuration: json['periodDuration'] as int?,
      lastPeriodDate: json['lastPeriodDate'] != null
          ? DateTime.parse(json['lastPeriodDate'] as String)
          : null,
      cycleRegular: json['cycleRegular'] as bool?,
      remindersEnabled: json['remindersEnabled'] as bool?,
    );
  }
}
