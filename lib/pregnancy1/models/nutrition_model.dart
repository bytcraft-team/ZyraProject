class NutritionModel {
  final int weekNumber;
  final String category;
  final String name;
  final String shortBenefit;
  final String detailedDescription;
  final String nutrients;
  final String recommendedQuantity;
  final String consumptionAdvice;
  final String precautions;
  final String mealType;
  final String imageUrl;

  NutritionModel({
    required this.weekNumber,
    required this.category,
    required this.name,
    required this.shortBenefit,
    required this.detailedDescription,
    required this.nutrients,
    required this.recommendedQuantity,
    required this.consumptionAdvice,
    required this.precautions,
    required this.mealType,
    required this.imageUrl,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      weekNumber: json['week_number'] as int,
      category: (json['category'] as String? ?? '').toLowerCase(),
      name: json['name'] as String? ?? '',
      shortBenefit: json['short_benefit'] as String? ?? '',
      detailedDescription: json['detailed_description'] as String? ?? '',
      nutrients: json['nutrients'] as String? ?? '',
      recommendedQuantity: json['recommended_quantity'] as String? ?? '',
      consumptionAdvice: json['consumption_advice'] as String? ?? '',
      precautions: json['precautions'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_number': weekNumber,
      'category': category,
      'name': name,
      'short_benefit': shortBenefit,
      'detailed_description': detailedDescription,
      'nutrients': nutrients,
      'recommended_quantity': recommendedQuantity,
      'consumption_advice': consumptionAdvice,
      'precautions': precautions,
      'meal_type': mealType,
      'image_url': imageUrl,
    };
  }

  List<String> get nutrientList {
    return nutrients
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String get categoryLabel {
    switch (category) {
      case 'protein':
        return 'Protéines';
      case 'vegetable':
        return 'Légumes';
      case 'fruit':
        return 'Fruits';
      default:
        return category.isEmpty
            ? 'Aliment'
            : '${category[0].toUpperCase()}${category.substring(1)}';
    }
  }

  String get mealTypeLabel {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Petit-déjeuner';
      case 'lunch':
        return 'Déjeuner';
      case 'dinner':
        return 'Dîner';
      case 'snack':
        return 'En-cas';
      default:
        return mealType.isEmpty
            ? 'Repas'
            : '${mealType[0].toUpperCase()}${mealType.substring(1)}';
    }
  }
}
