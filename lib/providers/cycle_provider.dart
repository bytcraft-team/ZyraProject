import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../repositories/cycle_repository.dart';
 
class CycleProvider extends ChangeNotifier {
  final CycleRepository _repository = CycleRepository();
 
  CycleModel? _cycle;
  bool _isLoading = false;
  bool _isSaved = false;
  String? _errorMessage;
 
  CycleModel? get cycle => _cycle;
  bool get isLoading => _isLoading;
  bool get isSaved => _isSaved;
  String? get errorMessage => _errorMessage;
 
  // Getters calculés directement utilisables dans l'UI
  int get dureeCycle => _cycle?.dureeCycle ?? 28;
  int get dureeRegles => _cycle?.dureeRegles ?? 5;
  DateTime get derniereRegles =>
      _cycle?.derniereRegles ?? DateTime.now();
  bool get modeGrossesse => _cycle?.modeGrossesse ?? false;
  DateTime? get prochaineRegles => _cycle?.prochaineRegles;
  DateTime? get dateOvulation => _cycle?.dateOvulation;
  int? get joursAvantRegles => _cycle?.joursAvantRegles;
 
  // ── Charger le cycle au démarrage ────────────────────────
  Future<void> load(String userId) async {
    _isLoading = true;
    notifyListeners();
    _cycle = await _repository.getCycle(userId);
    _isLoading = false;
    notifyListeners();
  }
 
  // ── Sauvegarder le cycle ─────────────────────────────────
  Future<bool> saveCycle({
    required String userId,
    required int dureeCycle,
    required int dureeRegles,
    required DateTime derniereRegles,
    required bool modeGrossesse,
  }) async {
    _isLoading = true;
    _isSaved = false;
    _errorMessage = null;
    notifyListeners();
 
    final result = await _repository.saveCycle(
      userId: userId,
      dureeCycle: dureeCycle,
      dureeRegles: dureeRegles,
      derniereRegles: derniereRegles,
      modeGrossesse: modeGrossesse,
    );
 
    _isLoading = false;
 
    if (result.success) {
      _cycle = result.data;
      _isSaved = true;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }
 
  bool estJourRegles(DateTime date) =>
      _cycle?.estJourRegles(date) ?? false;
  bool estJourFertile(DateTime date) =>
      _cycle?.estJourFertile(date) ?? false;
  bool estJourOvulation(DateTime date) =>
      _cycle?.estJourOvulation(date) ?? false;
 
  void clearError() {
    _errorMessage = null;
    _isSaved = false;
    notifyListeners();
  }
}