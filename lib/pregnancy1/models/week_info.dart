class WeekInfo {
  final String id;
  final int weekNumber;
  final String pregnancyInfo;
  final double babyLengthCm;
  final double babyWeightGrams;
  final String babyFruitComparison;
  final String babyDevelopmentDetails;
  final String motherTips;
  final String imageUrl;

  // 1. Standard Constructor with required parameters
  WeekInfo({
    required this.id,
    required this.weekNumber,
    required this.pregnancyInfo,
    required this.babyLengthCm,
    required this.babyWeightGrams,
    required this.babyFruitComparison,
    required this.babyDevelopmentDetails,
    required this.motherTips,
    required this.imageUrl,
  });

  // 2. Factory constructor to create a WeekInfo instance from a Map (JSON)
  factory WeekInfo.fromJson(Map<String, dynamic> json) {
    return WeekInfo(
      id: json['id'] as String? ?? '',
      weekNumber: json['weekNumber'] as int? ?? 0,
      pregnancyInfo: json['pregnancyInfo'] as String? ?? '',
      // .toDouble() handles cases where the JSON number might arrive without a decimal point
      babyLengthCm: (json['babyLengthCm'] as num?)?.toDouble() ?? 0.0,
      babyWeightGrams: (json['babyWeightGrams'] as num?)?.toDouble() ?? 0.0,
      babyFruitComparison: json['babyFruitComparison'] as String? ?? '',
      babyDevelopmentDetails: json['babyDevelopmentDetails'] as String? ?? '',
      motherTips: json['motherTips'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
