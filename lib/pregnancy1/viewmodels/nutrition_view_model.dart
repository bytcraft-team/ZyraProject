import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/nutrition_model.dart';

class NutritionViewModel extends ChangeNotifier {
  static const categories = ['protein', 'vegetable', 'fruit'];

  final int initialWeek;
  bool nutritionTipsEnabled;

  bool isLoading = false;
  String? errorMessage;
  List<NutritionModel> items = [];
  int selectedWeek;
  String selectedCategory = 'vegetable';
  bool _disposed = false;

  NutritionViewModel({int currentWeek = 4, this.nutritionTipsEnabled = true})
    : initialWeek = currentWeek,
      selectedWeek = max(4, currentWeek);

  int get effectiveWeek => max(4, selectedWeek);

  bool get isPreviewMode => initialWeek < 4;

  String get headerSubtitle {
    if (!nutritionTipsEnabled) {
      return 'Activez les conseils de grossesse pour recevoir un plan nutritionnel.';
    }
    if (isPreviewMode) {
      return 'Vos recommandations commencent dès la semaine 4 de grossesse.';
    }
    return 'Conseils nutritionnels personnalisés pour la semaine $effectiveWeek.';
  }

  String get weekLabel => 'Semaine $effectiveWeek';

  String get currentSummary {
    if (!nutritionTipsEnabled) {
      return 'Aucune donnée de grossesse détectée. Répondez au questionnaire pour activer les conseils nutritionnels.';
    }
    if (isPreviewMode) {
      return 'Les recommandations ciblées débutent à partir de la semaine 4.';
    }
    return 'Basé sur votre semaine actuelle de grossesse.';
  }

  List<NutritionModel> get filteredList {
    return items
        .where(
          (item) =>
              item.weekNumber == effectiveWeek &&
              item.category == selectedCategory,
        )
        .toList();
  }

  List<int> get availableWeeks {
    final weekSet = items.map((item) => item.weekNumber).toSet();
    final weeks = weekSet.toList()..sort();
    return weeks.where((week) => week >= 4).toList();
  }

  Future<void> initialize() async {
    if (_disposed) return;

    errorMessage = null;
    _setLoading(true);
    try {
      final rawJson = await rootBundle.loadString('assets/nutrition.json');
      if (_disposed) return;

      final decoded = jsonDecode(rawJson) as List<dynamic>;
      items = decoded
          .map((item) => NutritionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (items.isEmpty) {
        errorMessage = 'Aucune donnée nutritionnelle disponible.';
        return;
      }

      if (!availableWeeks.contains(selectedWeek)) {
        selectedWeek = availableWeeks.isNotEmpty ? availableWeeks.first : 4;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      errorMessage =
          'Impossible de charger les conseils nutritionnels depuis les ressources locales.';
    } finally {
      _setLoading(false);
    }
  }

  void updateWeek(int week) {
    if (_disposed) return;

    final adjustedWeek = max(4, week);
    if (selectedWeek == adjustedWeek) return;
    selectedWeek = adjustedWeek;
    notifyListeners();
  }

  void setPregnancyState({required int currentWeek, required bool enabled}) {
    if (_disposed) return;

    final adjustedWeek = max(4, currentWeek);
    var changed = false;
    if (nutritionTipsEnabled != enabled) {
      nutritionTipsEnabled = enabled;
      changed = true;
    }
    if (selectedWeek != adjustedWeek) {
      selectedWeek = adjustedWeek;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void updateCategory(String category) {
    if (_disposed) return;

    if (selectedCategory == category) return;
    selectedCategory = category;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_disposed) return;

    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
