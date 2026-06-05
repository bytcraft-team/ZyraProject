class UserAnswersModel {
  final DateTime lastPeriodDate;
  final int cycleLength;
  final bool pregnancyConfirmed;

  UserAnswersModel({
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.pregnancyConfirmed,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'cycleLength': cycleLength,
      'pregnancyConfirmed': pregnancyConfirmed,
    };
  }

  factory UserAnswersModel.fromJson(Map<String, dynamic> json) {
    return UserAnswersModel(
      lastPeriodDate: DateTime.parse(json['lastPeriodDate'] as String),
      cycleLength: json['cycleLength'] as int? ?? 28,
      pregnancyConfirmed: json['pregnancyConfirmed'] as bool? ?? false,
    );
  }
}
