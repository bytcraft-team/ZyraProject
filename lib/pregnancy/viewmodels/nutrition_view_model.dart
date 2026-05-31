import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/nutrition_model.dart';

class NutritionViewModel extends ChangeNotifier {
  static const categories = ['protein', 'vegetable', 'fruit'];

  final int? initialWeek;
  bool isLoading = false;
  String? errorMessage;
  List<NutritionModel> items = [];
  int selectedWeek;
  String selectedCategory = 'vegetable';

  NutritionViewModel({int? currentWeek})
      : initialWeek = currentWeek,
        selectedWeek = currentWeek ?? 4;

  List<NutritionModel> get filteredList {
    return items
        .where(
          (item) => item.weekNumber == selectedWeek &&
              item.category == selectedCategory,
        )
        .toList();
  }

  List<int> get availableWeeks {
    final weekSet = items.map((item) => item.weekNumber).toSet();
    final weeks = weekSet.toList()..sort();
    return weeks;
  }

  Future<void> initialize() async {
    errorMessage = null;
    _setLoading(true);
    try {
      final rawJson = await rootBundle.loadString('assets/nutrition.json');
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      items = decoded
          .map((item) => NutritionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (items.isEmpty) {
        errorMessage = 'Aucune donnée nutritionnelle disponible.';
        return;
      }

      if (!availableWeeks.contains(selectedWeek)) {
        selectedWeek = initialWeek ?? availableWeeks.first;
        if (!availableWeeks.contains(selectedWeek)) {
          selectedWeek = availableWeeks.first;
        }
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      errorMessage = 'Impossible de charger les conseils nutritionnels.';
    } finally {
      _setLoading(false);
    }
  }

  void updateWeek(int week) {
    if (selectedWeek == week) return;
    selectedWeek = week;
    notifyListeners();
  }

  void updateCategory(String category) {
    if (selectedCategory == category) return;
    selectedCategory = category;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
