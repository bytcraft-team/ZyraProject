import 'package:flutter/foundation.dart';
import '../repositories/user_repository.dart';
import '../services/week_data_service.dart';
import '../services/pregnancy_calculator.dart';
import '../models/week_info.dart';
import '../models/pregnancy_tracking.dart';

enum PregnancyViewState { idle, loading, success, error }

class PregnancyViewModel extends ChangeNotifier {
  final WeekDataService _weekDataService = WeekDataService();
  final UserRepository _userRepository;

  PregnancyViewModel({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  PregnancyViewState _state = PregnancyViewState.idle;
  PregnancyViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  WeekInfo? _currentWeekInfo;
  WeekInfo? get currentWeekInfo => _currentWeekInfo;

  PregnancyTracking? _pregnancyTracking;
  PregnancyTracking? get pregnancyTracking => _pregnancyTracking;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Cache pour éviter les appels API répétés
  final Map<int, WeekInfo> _weekInfoCache = {};

  /// Initialise le ViewModel avec les données de suivi de grossesse
  /// Effectue les calculs complets basés sur la date LMP
  Future<void> initializeWithPregnancyData(DateTime pregnancyStartDate) async {
    _state = PregnancyViewState.loading;
    _isLoading = true;
    notifyListeners();

    try {
      // Recalcule tous les paramètres basés sur la date LMP
      final currentWeek =
          PregnancyCalculator.calculateCurrentWeek(pregnancyStartDate);
      final adjustedWeek = PregnancyCalculator.validateWeekNumber(currentWeek);
      final daysInCurrentWeek =
          PregnancyCalculator.calculateDaysInCurrentWeek(pregnancyStartDate);
      final daysRemaining =
          PregnancyCalculator.calculateDaysRemaining(pregnancyStartDate);
      final expectedDeliveryDate =
          PregnancyCalculator.calculateExpectedDeliveryDate(pregnancyStartDate);
      final trimester = PregnancyCalculator.calculateTrimester(adjustedWeek);

      _pregnancyTracking = PregnancyTracking(
        pregnancyStartDate: pregnancyStartDate,
        currentWeek: adjustedWeek,
        daysInCurrentWeek: daysInCurrentWeek,
        daysRemaining: daysRemaining,
        trimester: trimester,
        expectedDeliveryDate: expectedDeliveryDate,
      );

      // Récupère les données de la semaine actuelle depuis l'API
      await loadWeekInfo(adjustedWeek);

      _state = PregnancyViewState.success;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'initialisation: $e';
      _state = PregnancyViewState.error;
      debugPrint('Erreur PregnancyViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les informations d'une semaine spécifique
  Future<void> loadWeekInfo(int weekNumber) async {
    try {
      final adjustedWeek = PregnancyCalculator.validateWeekNumber(weekNumber);

      // Vérifier le cache d'abord
      if (_weekInfoCache.containsKey(adjustedWeek)) {
        _currentWeekInfo = _weekInfoCache[adjustedWeek];
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      final weekInfo = await _weekDataService.fetchWeekInfo(adjustedWeek);
      if (weekInfo != null) {
        _currentWeekInfo = weekInfo;
        _weekInfoCache[adjustedWeek] = weekInfo;
        _errorMessage = null;
        _state = PregnancyViewState.success;
      } else {
        _errorMessage =
            'Impossible de charger les données de la semaine $adjustedWeek';
        _state = PregnancyViewState.error;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données: $e';
      _state = PregnancyViewState.error;
      debugPrint('Erreur loadWeekInfo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recalcule automatiquement la semaine actuelle et met à jour les données
  /// Appelé à chaque ouverture de l'application pour assurer que les données
  /// restent toujours exactes même si l'utilisatrice n'ouvre pas l'application pendant plusieurs jours
  Future<void> recalculateCurrentWeek() async {
    if (_pregnancyTracking == null) return;

    try {
      // Recalcule tous les paramètres basés sur la date LMP stockée
      final lmpDate = _pregnancyTracking!.pregnancyStartDate;
      final newWeek = PregnancyCalculator.calculateCurrentWeek(lmpDate);
      final adjustedWeek = PregnancyCalculator.validateWeekNumber(newWeek);
      final newDaysInWeek =
          PregnancyCalculator.calculateDaysInCurrentWeek(lmpDate);
      final newDaysRemaining =
          PregnancyCalculator.calculateDaysRemaining(lmpDate);
      final newTrimester = PregnancyCalculator.calculateTrimester(adjustedWeek);

      // Met à jour le suivi de grossesse
      _pregnancyTracking = _pregnancyTracking!.copyWith(
        currentWeek: adjustedWeek,
        daysInCurrentWeek: newDaysInWeek,
        daysRemaining: newDaysRemaining,
        trimester: newTrimester,
        lastCalculatedAt: DateTime.now(),
      );

      // Recharge les données de la nouvelle semaine si changement
      if (adjustedWeek != _currentWeekInfo?.weekNumber) {
        await loadWeekInfo(adjustedWeek);
      }

      _state = PregnancyViewState.success;
    } catch (e) {
      _errorMessage = 'Erreur lors du recalcul: $e';
      _state = PregnancyViewState.error;
      debugPrint('Erreur recalculateCurrentWeek: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Obtient le chemin local de l'image pour la semaine actuelle
  String? getLocalImagePath() {
    if (_currentWeekInfo?.imageUrl == null) return null;
    return WeekDataService.buildLocalImagePath(_currentWeekInfo!.imageUrl);
  }

  /// Obtient le label du trimestre courant
  String getCurrentTrimesterLabel() {
    if (_pregnancyTracking == null) return '';
    return PregnancyCalculator.getTrimesterLabel(
        _pregnancyTracking!.currentWeek);
  }

  /// Exporte les données de suivi pour Firestore
  Map<String, dynamic> exportToFirestore() {
    return _pregnancyTracking?.toFirestore() ?? {};
  }

  /// Restaure à partir des données Firestore
  void restoreFromFirestore(Map<String, dynamic> data) {
    try {
      _pregnancyTracking = PregnancyTracking.fromFirestore(data);
      _state = PregnancyViewState.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la restauration des données: $e';
      _state = PregnancyViewState.error;
      debugPrint('Erreur restoreFromFirestore: $e');
    }
  }

  /// Charge les données de suivi de grossesse depuis Firestore
  Future<void> loadTrackingFromFirestore() async {
    _state = PregnancyViewState.loading;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _userRepository.loadPregnancyTracking();
      if (data == null) {
        _state = PregnancyViewState.idle;
        _errorMessage = null;
      } else {
        restoreFromFirestore(data);
        if (_pregnancyTracking != null) {
          await recalculateCurrentWeek();
          await loadWeekInfo(_pregnancyTracking!.currentWeek);
          _state = PregnancyViewState.success;
        }
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données Firestore: $e';
      _state = PregnancyViewState.error;
      debugPrint('Erreur loadTrackingFromFirestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vide le cache
  void clearCache() {
    _weekInfoCache.clear();
  }
}
