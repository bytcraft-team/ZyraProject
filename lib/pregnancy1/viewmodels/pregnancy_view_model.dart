import 'package:flutter/foundation.dart';
import '../repositories/user_repository.dart';
import '../../database/pregnancy_dao.dart';
import '../../services/connectivity_service.dart';
import '../services/week_data_service.dart';
import '../services/pregnancy_calculator.dart';
import '../models/week_info.dart';
import '../models/pregnancy_tracking.dart';

enum PregnancyViewState { idle, loading, success, error }

class PregnancyViewModel extends ChangeNotifier {
  final WeekDataService _weekDataService = WeekDataService();
  final PregnancyDao _pregnancyDao = PregnancyDao();
  final ConnectivityService _connectivityService = ConnectivityService();
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
      final currentWeek = PregnancyCalculator.calculateCurrentWeek(
        pregnancyStartDate,
      );
      final adjustedWeek = PregnancyCalculator.validateWeekNumber(currentWeek);
      final daysInCurrentWeek = PregnancyCalculator.calculateDaysInCurrentWeek(
        pregnancyStartDate,
      );
      final daysRemaining = PregnancyCalculator.calculateDaysRemaining(
        pregnancyStartDate,
      );
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
      final userId = _userRepository.currentUser?.uid;

      // Vérifier le cache d'abord
      if (_weekInfoCache.containsKey(adjustedWeek)) {
        _currentWeekInfo = _weekInfoCache[adjustedWeek];
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      WeekInfo? weekInfo;
      final hasInternet = await _connectivityService.hasInternetConnection();

      if (hasInternet) {
        weekInfo = await _weekDataService.fetchWeekInfo(adjustedWeek);
        if (weekInfo != null && userId != null) {
          await _pregnancyDao.saveWeekInfo(userId, adjustedWeek, {
            'id': weekInfo.id,
            'weekNumber': weekInfo.weekNumber,
            'pregnancyInfo': weekInfo.pregnancyInfo,
            'babyLengthCm': weekInfo.babyLengthCm,
            'babyWeightGrams': weekInfo.babyWeightGrams,
            'babyFruitComparison': weekInfo.babyFruitComparison,
            'babyDevelopmentDetails': weekInfo.babyDevelopmentDetails,
            'motherTips': weekInfo.motherTips,
            'imageUrl': weekInfo.imageUrl,
          });
        }
      }

      if (weekInfo == null && userId != null) {
        final localWeekInfo = await _pregnancyDao.getWeekInfo(
          userId,
          adjustedWeek,
        );
        if (localWeekInfo != null) {
          weekInfo = WeekInfo.fromJson(localWeekInfo);
        }
      }

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
      final newDaysInWeek = PregnancyCalculator.calculateDaysInCurrentWeek(
        lmpDate,
      );
      final newDaysRemaining = PregnancyCalculator.calculateDaysRemaining(
        lmpDate,
      );
      final newTrimester = PregnancyCalculator.calculateTrimester(adjustedWeek);

      // Met à jour le suivi de grossesse
      final newExpectedDeliveryDate =
          PregnancyCalculator.calculateExpectedDeliveryDate(lmpDate);

      _pregnancyTracking = _pregnancyTracking!.copyWith(
        currentWeek: adjustedWeek,
        daysInCurrentWeek: newDaysInWeek,
        daysRemaining: newDaysRemaining,
        trimester: newTrimester,
        expectedDeliveryDate: newExpectedDeliveryDate,
        lastCalculatedAt: DateTime.now(),
      );

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

  String? getLocalImagePath() {
    if (_currentWeekInfo?.imageUrl == null) return null;
    
    return WeekDataService.buildLocalImagePath(_currentWeekInfo!.imageUrl);
  }

  String getCurrentTrimesterLabel() {
    if (_pregnancyTracking == null) return '';
    return PregnancyCalculator.getTrimesterLabel(
      _pregnancyTracking!.currentWeek,
    );
  }

  Map<String, dynamic> exportToFirestore() {
    return _pregnancyTracking?.toFirestore() ?? {};
  }

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
      final userId = _userRepository.currentUser?.uid;
      if (userId == null) {
        _state = PregnancyViewState.idle;
        _errorMessage = null;
        return;
      }

      final hasInternet = await _connectivityService.hasInternetConnection();
      Map<String, dynamic>? data;

      if (hasInternet) {
        data = await _userRepository.loadPregnancyTracking();
      }

      data ??= await _pregnancyDao.loadPregnancyTracking(userId);

      if (data == null) {
        _state = PregnancyViewState.idle;
        _errorMessage = null;
      } else {
        restoreFromFirestore(data);
        if (_pregnancyTracking != null) {
          await recalculateCurrentWeek();
          await _pregnancyDao.savePregnancyTracking(
            userId,
            exportToFirestore(),
          );
          _state = PregnancyViewState.success;
        }
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données de grossesse: $e';
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
