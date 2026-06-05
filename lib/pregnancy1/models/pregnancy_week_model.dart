class PregnancyWeekModel {
  final String id;
  final int weekNumber;
  final String pregnancyInfo;
  final double babyLengthCm;
  final double babyWeightGrams;
  final String babyFruitComparison;
  final String babyDevelopmentDetails;
  final String motherTips;
  final String imageKey;

  PregnancyWeekModel({
    required this.id,
    required this.weekNumber,
    required this.pregnancyInfo,
    required this.babyLengthCm,
    required this.babyWeightGrams,
    required this.babyFruitComparison,
    required this.babyDevelopmentDetails,
    required this.motherTips,
    required this.imageKey,
  });

  factory PregnancyWeekModel.fromJson(Map<String, dynamic> json) {
    return PregnancyWeekModel(
      id: json['id'] as String? ?? '',
      weekNumber: json['weekNumber'] as int? ?? 0,
      pregnancyInfo: json['pregnancyInfo'] as String? ?? '',
      babyLengthCm: (json['babyLengthCm'] as num?)?.toDouble() ?? 0.0,
      babyWeightGrams: (json['babyWeightGrams'] as num?)?.toDouble() ?? 0.0,
      babyFruitComparison: json['babyFruitComparison'] as String? ?? '',
      babyDevelopmentDetails: json['babyDevelopmentDetails'] as String? ?? '',
      motherTips: json['motherTips'] as String? ?? '',
      imageKey: json['imageUrl'] as String? ?? '',
    );
  }

  String? get imageAsset {
    if (imageKey.isEmpty) return null;
    return 'assets/images/$imageKey.png';
  }
}
