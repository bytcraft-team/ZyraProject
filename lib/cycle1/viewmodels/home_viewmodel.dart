import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/cycle_model.dart';
import '../data/models/user_model.dart';
import '../data/models/day_info_model.dart';
import '../data/repositories/cycle_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/models/settings_model.dart';
import '../core/utils/cycle_utils.dart';
import '../core/utils/date_utils.dart';

enum ViewState { idle, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final CycleRepository _repository;
  StreamSubscription<DateTime>? _dailyLogSub;
  StreamSubscription<User?>? _authSub;

  HomeViewModel({required CycleRepository repository})
      : _repository = repository {
    // s'abonner aux modifications des daily logs pour rafraîchir le mois actif
    try {
      _dailyLogSub = _repository.onDailyLogChanged.listen((date) {
        if (date.year == _selectedMonth.year && date.month == _selectedMonth.month) {
          _loadMonthDays();
        }
      });
    } catch (_) {}

    // Listen to FirebaseAuth user changes to refresh displayed user info
    try {
      _authSub = FirebaseAuth.instance.userChanges().listen((_) async {
        await loadData();
      });
    } catch (_) {}
  }

  // State
  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  // Data
  UserModel? _user;
  UserModel? get user => _user;

  // Ce modèle contient maintenant : startDate, cycleDuration, expectedPeriodDuration, regularity
  CycleModel? _cycle;
  CycleModel? get cycle => _cycle;

  List<DayInfoModel> _monthDays = [];
  List<DayInfoModel> get monthDays => _monthDays;


  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  CyclePhase? _selectedPhaseFilter;
  CyclePhase? get selectedPhaseFilter => _selectedPhaseFilter;

  bool _isAnimationComplete = false;
  bool get isAnimationComplete => _isAnimationComplete;

  // ──────────────────────────────────────────────
  // Computed properties (LOGIQUE SÉCURISÉE ET CORRIGÉE)
  // ──────────────────────────────────────────────

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour ';
    if (hour < 18) return 'Bon après-midi ';
    return 'Bonsoir ';
  }

  /// Calcule dynamiquement la date des prochaines règles
  String get nextPeriodDateFormatted {
    if (_cycle == null) return '—';
    
    final DateTime nextDate = CycleUtils.nextPeriodDate(
      lastPeriodStart: _cycle!.startDate,
      cycleDuration: _cycle!.cycleDuration,
    );
    
    const months = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${nextDate.day} ${months[nextDate.month]}';
  }

  /// Calcule le pourcentage de progression via CycleUtils
  String get cycleProgressPercent {
    if (_cycle == null) return '0%';
    final percent = CycleUtils.cycleProgressPercent(
      lastPeriodStart: _cycle!.startDate,
      cycleDuration: _cycle!.cycleDuration,
    );
    return '$percent%';
  }

  /// Renvoyer un double entre 0.0 et 1.0 pour l'indicateur circulaire de l'UI
  double get cycleProgress {
    if (_cycle == null) return 0.0;
    return CycleUtils.cycleProgress(
      lastPeriodStart: _cycle!.startDate,
      cycleDuration: _cycle!.cycleDuration,
    );
  }

  String get regularityLabel {
    if (_cycle == null) return '—';
    return _cycle!.regularity;
  }

  

  String get selectedMonthLabel {
    const months = [
      '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[_selectedMonth.month]} ${_selectedMonth.year}';
  }

  /// Détermine la fertilité du jour à partir de la phase dynamique calculée
  FertilityLevel get todayFertility {
    if (_cycle == null) return FertilityLevel.low;
    
    final currentPhase = CycleUtils.currentPhase(
      lastPeriodStart: _cycle!.startDate,
      cycleDuration: _cycle!.cycleDuration,
      periodDuration: _cycle!.expectedPeriodDuration,
    );

    switch (currentPhase) {
      case CyclePhase.rules:
        return FertilityLevel.low;
      case CyclePhase.fertile:
        return FertilityLevel.medium;
      case CyclePhase.ovulation:
        return FertilityLevel.veryHigh;
      case CyclePhase.luteal:
        return FertilityLevel.low;
    }
  }

  // ──────────────────────────────────────────────
  // Actions
  // ──────────────────────────────────────────────

  Future<void> loadData() async {
    _setState(ViewState.loading);
    try {
      final user = await _repository.getUser();
      final currentCycle = await _repository.getCurrentCycle();

      CycleModel? effectiveCycle = currentCycle;
      if (effectiveCycle == null) {
        try {
          final settingsRepo = SettingsRepositoryImpl();
          final settings = await settingsRepo.getSettings();
          if (settings.onboardingCompleted && settings.lastPeriodStart != null) {
            final start = settings.lastPeriodStart!;
            final predictedOvulation = start.add(Duration(days: settings.cycleDuration - 14));
            effectiveCycle = CycleModel(
              id: 'onboard-${start.millisecondsSinceEpoch}',
              startDate: start,
              endDate: null,
              predictedOvulation: predictedOvulation,
              predictedFertilityStart: predictedOvulation.subtract(const Duration(days: 5)),
              predictedFertilityEnd: predictedOvulation.add(const Duration(days: 1)),
              cycleDuration: settings.cycleDuration,
              expectedPeriodDuration: settings.periodDuration,
              regularity: settings.regularity.label,
              lastUpdated: DateTime.now(),
              isSynced: 1,
            );
          }
        } catch (e) {
          debugPrint('Impossible de lire Settings pour onboarding fallback: $e');
        }
      }

      final finalCycle = effectiveCycle ?? _buildFallbackCycle();
      final monthDays = await _repository.getMonthDays(_selectedMonth);
      _user = user;
      _cycle = finalCycle;
      _monthDays = monthDays;
      
      _errorMessage = null;
      _setState(ViewState.success);

      // Lancement de la synchronisation vers Firebase en tâche de fond
      _repository.syncLocalToFirebase();
    } catch (e, stack) {
      debugPrint('Erreur HomeViewModel loadData capturée : $e');
      debugPrint('$stack');

      _user = _defaultUser();
      _cycle = _buildFallbackCycle();
      _monthDays = _buildFallbackMonthDays(_selectedMonth, _cycle!);
      
      _errorMessage = 'Affichage de secours activé';
      _setState(ViewState.success);
    }
  }

  void selectPhase(CyclePhase? phase) {
    _selectedPhaseFilter = phase;
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
    );
    _loadMonthDays();
  }

  void nextMonth() {
    _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
    );
    _loadMonthDays();
  }

  void onAnimationComplete() {
    _isAnimationComplete = true;
    notifyListeners();
  }

  Future<void> _loadMonthDays() async {
    try {
      _monthDays = await _repository.getMonthDays(_selectedMonth);
      notifyListeners();
    } catch (e, stack) {
      debugPrint('Erreur _loadMonthDays : $e');
      debugPrint('$stack');
      _monthDays = _buildFallbackMonthDays(_selectedMonth, _cycle ?? _buildFallbackCycle());
      notifyListeners();
    }
  }

  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  CycleModel _buildFallbackCycle() {
    final now = DateTime.now();
    final predictedOvulation = now.add(const Duration(days: 14));
    return CycleModel(
      id: 'fallback-${now.millisecondsSinceEpoch}',
      startDate: now,
      endDate: null,
      predictedOvulation: predictedOvulation,
      predictedFertilityStart: predictedOvulation.subtract(const Duration(days: 5)),
      predictedFertilityEnd: predictedOvulation.add(const Duration(days: 1)),
      cycleDuration: 28,
      expectedPeriodDuration: 5,
      regularity: 'Régulier',
      lastUpdated: now,
      isSynced: 1,
    );
  }

  UserModel _defaultUser() {
    return const UserModel(
      firstName: 'Utilisateur',
      lastName: null,
      hasUnreadNotifications: false,
      unreadNotificationCount: 0,
    );
  }

  List<DayInfoModel> _buildFallbackMonthDays(DateTime month, CycleModel cycle) {
    final now = CycleDateUtils.dateOnly(DateTime.now());
    final daysInMonth = CycleDateUtils.daysInMonth(month.year, month.month);

    return List.generate(daysInMonth, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final rawDayInCycle = CycleDateUtils.daysBetween(cycle.startDate, date) + 1;
      final dayInCycle = rawDayInCycle > 0 ? rawDayInCycle : 1;
      final phase = CycleUtils.phaseForDay(
        day: dayInCycle,
        cycleDuration: cycle.cycleDuration,
        periodDuration: cycle.expectedPeriodDuration,
      );
      final fertility = CycleUtils.fertilityForDay(
        day: dayInCycle,
        cycleDuration: cycle.cycleDuration,
      );
      final isPredicted = date.isAfter(now);

      return DayInfoModel(
        date: date,
        dayInCycle: dayInCycle,
        phase: phase,
        fertilityLevel: fertility,
        isPredicted: isPredicted,
      );
    });
  }

  DayInfoModel? getDayInfo(DateTime date) {
    try {
      return _monthDays.firstWhere(
        (d) =>
            d.date.day == date.day &&
            d.date.month == date.month &&
            d.date.year == date.year,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _dailyLogSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}