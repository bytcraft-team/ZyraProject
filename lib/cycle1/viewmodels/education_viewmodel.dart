import 'package:zyra/cycle1/data/models/cycle_model.dart';
import 'package:flutter/foundation.dart';
// Contient CyclePhase, MoodType, SymptomType, etc.
import '../data/models/education_model.dart';

class EducationViewModel extends ChangeNotifier {
  // ── Onglet actif ─────────────────────────────────────────────
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  CyclePhase get selectedPhase =>
      CyclePhase.values[_selectedTabIndex];

  // ── Contenu éducatif ─────────────────────────────────────────
  PhaseEducationContent get currentContent =>
      PhaseEducationContent.forPhase(selectedPhase);

  // ── Symptôme sélectionné (chip) ───────────────────────────────
  int? _selectedSymptomIndex;
  int? get selectedSymptomIndex => _selectedSymptomIndex;

  EducationSymptom? get selectedSymptom {
    if (_selectedSymptomIndex == null) return null;
    final symptoms = currentContent.symptoms;
    if (_selectedSymptomIndex! >= symptoms.length) return null;
    return symptoms[_selectedSymptomIndex!];
  }

  // ── Actions ───────────────────────────────────────────────────

  void selectTab(int index) {
    if (index == _selectedTabIndex) return;
    if (index < 0 || index >= CyclePhase.values.length) return;
    
    _selectedTabIndex = index;
    _selectedSymptomIndex = null; // Reset de la chip sélectionnée lors d'un changement d'onglet
    notifyListeners();
  }

  void toggleSymptom(int index) {
    if (_selectedSymptomIndex == index) {
      _selectedSymptomIndex = null;
    } else {
      _selectedSymptomIndex = index;
    }
    notifyListeners();
  }

  void clearSymptom() {
    _selectedSymptomIndex = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────

  bool isSymptomSelected(int index) => _selectedSymptomIndex == index;

  /// Passer à la phase suivante (navigation circulaire)
  void nextPhase() {
    final next = (_selectedTabIndex + 1) % CyclePhase.values.length;
    selectTab(next);
  }

  /// Retourner à la phase précédente (navigation circulaire)
  void previousPhase() {
    final prev = (_selectedTabIndex - 1 + CyclePhase.values.length) %
        CyclePhase.values.length;
    selectTab(prev);
  }
}