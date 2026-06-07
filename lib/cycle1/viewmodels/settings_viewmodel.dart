import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/settings_model.dart';
import '../data/models/cycle_model.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/cycle_repository.dart';

enum SettingsLoadState { idle, loading, success, error }

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  // Injection du dépôt de cycle pour la double sauvegarde hybride
  final CycleRepository _cycleRepository = CycleRepositoryImpl();

  SettingsViewModel({required SettingsRepository repository})
    : _repository = repository;

  // ── State ────────────────────────────────────────────────────
  SettingsLoadState _state = SettingsLoadState.idle;
  SettingsLoadState get state => _state;

  CycleSettings? _settings;
  CycleSettings? get settings => _settings;

  // ── Onboarding ───────────────────────────────────────────────
  int _currentStep = 0;
  int get currentStep => _currentStep;
  static const int totalSteps = 5;

  bool get onboardingCompleted => _settings?.onboardingCompleted ?? false;

  bool get hasCompletedCycleQuestions =>
      _settings?.hasCompletedCycleQuestions ?? false;

  // Données onboarding en cours
  DateTime? _selectedLastPeriod;
  DateTime? get selectedLastPeriod => _selectedLastPeriod;

  int _cycleDuration = 28;
  int get cycleDuration => _cycleDuration;

  int _periodDuration = 5;
  int get periodDuration => _periodDuration;

  CycleRegularity _regularity = CycleRegularity.regular;
  CycleRegularity get regularity => _regularity;

  UserGoal _goal = UserGoal.simpleTracking;
  UserGoal get goal => _goal;

  // ── Notifications ────────────────────────────────────────────
  NotificationSettings get notifications =>
      _settings?.notifications ?? const NotificationSettings();

  // ── History ──────────────────────────────────────────────────
  List<CycleHistoryEntry> get history => _settings?.history ?? [];

  // ── Validation par étape ─────────────────────────────────────
  bool get canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedLastPeriod != null;
      case 1:
        return true;
      case 2:
        return true;
      case 3:
        return true;
      case 4:
        return true;
      default:
        return false;
    }
  }

  double get progressFraction => (_currentStep + 1) / totalSteps;

  // ─────────────────────────────────────────────────────────────
  // Chargement
  // ─────────────────────────────────────────────────────────────
  Future<void> init() async {
    _setState(SettingsLoadState.loading);
    try {
      _settings = await _repository.getSettings();
      debugPrint(
        'SettingsViewModel.init: loaded hasCompletedCycleQuestions=${_settings?.hasCompletedCycleQuestions}',
      );
      if (_settings != null) {
        _cycleDuration = _settings!.cycleDuration;
        _periodDuration = _settings!.periodDuration;
        _regularity = _settings!.regularity;
        _goal = _settings!.goal;
        _selectedLastPeriod = _settings!.lastPeriodStart;
      }
      _setState(SettingsLoadState.success);
    } catch (e) {
      debugPrint(
        'SettingsViewModel.init: erreur de chargement des settings: $e',
      );
      _setState(SettingsLoadState.error);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Onboarding — navigation
  // ─────────────────────────────────────────────────────────────
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Onboarding — saisie
  // ─────────────────────────────────────────────────────────────
  void selectLastPeriodDate(DateTime date) {
    _selectedLastPeriod = date;
    notifyListeners();
  }

  void setCycleDuration(int value) {
    _cycleDuration = value;
    notifyListeners();
  }

  void setPeriodDuration(int value) {
    _periodDuration = value;
    notifyListeners();
  }

  void setRegularity(CycleRegularity value) {
    _regularity = value;
    notifyListeners();
  }

  void setGoal(UserGoal value) {
    _goal = value;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Terminer l'onboarding (CALCULS BIOLOGIQUES + SAUVEGARDE)
  // ─────────────────────────────────────────────────────────────
  Future<bool> finishOnboarding() async {
    if (_selectedLastPeriod == null) return false;

    _setState(SettingsLoadState.loading);
    debugPrint('finishOnboarding: démarrage du flux de sauvegarde');

    try {
      final DateTime startDate = _selectedLastPeriod!;

      // 1. FORMULES BIOLOGIQUES : Calcul de l'ovulation et de la fertilité
      final int ovulationOffset = _cycleDuration - 14;
      final DateTime predictedOvulation = startDate.add(
        Duration(days: ovulationOffset),
      );
      final DateTime predictedFertilityStart = predictedOvulation.subtract(
        const Duration(days: 5),
      );
      final DateTime predictedFertilityEnd = predictedOvulation.add(
        const Duration(days: 1),
      );

      // 2. EXTRACTION DU LABEL DE LA RÉGULARITÉ DEPUIS L'EXTENSION
      final String regularityText = _regularity.label;

      // 3. ENCAPSULATION DU NOUVEAU CYCLE AVEC UN UUID UNIQUE
      final String uniqueId = const Uuid().v4();
      final CycleModel newCycle = CycleModel(
        id: uniqueId,
        startDate: startDate,
        endDate: null,
        predictedOvulation: predictedOvulation,
        predictedFertilityStart: predictedFertilityStart,
        predictedFertilityEnd: predictedFertilityEnd,
        cycleDuration: _cycleDuration,
        expectedPeriodDuration: _periodDuration,
        regularity: regularityText,
        lastUpdated: DateTime.now(),
        isSynced: 0,
      );

      // 4. PERSISTANCE DOUBLE EN BASE DE DONNÉES
      await _cycleRepository.saveCycle(newCycle);

      final newSettings = (_settings ?? const CycleSettings()).copyWith(
        onboardingCompleted: true,
        hasCompletedCycleQuestions: true,
        lastPeriodStart: _selectedLastPeriod,
        cycleDuration: _cycleDuration,
        periodDuration: _periodDuration,
        regularity: _regularity,
        goal: _goal,
      );
      final success = await _repository.completeOnboarding(newSettings);

      if (!success) {
        debugPrint(
          'finishOnboarding: Firestore sync failed, onboarding not fully committed.',
        );
        _setState(SettingsLoadState.error);
        return false;
      }

      _settings = newSettings;
      _setState(SettingsLoadState.success);
      debugPrint('finishOnboarding: sauvegarde locale et Firestore terminées');
      return true;
    } catch (e, stack) {
      debugPrint('Erreur finishOnboarding : $e\n$stack');
      _setState(SettingsLoadState.error);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Notifications
  // ─────────────────────────────────────────────────────────────
  Future<void> toggleDailyReminder(bool value) async {
    await _updateNotifs(
      _settings!.notifications.copyWith(dailyJournalReminder: value),
    );
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    await _updateNotifs(
      _settings!.notifications.copyWith(dailyReminderTime: time),
    );
  }

  Future<void> togglePeriodAlert(bool value) async {
    await _updateNotifs(
      _settings!.notifications.copyWith(periodInTwoDaysAlert: value),
    );
  }

  Future<void> toggleFertileAlert(bool value) async {
    await _updateNotifs(
      _settings!.notifications.copyWith(fertileWindowAlert: value),
    );
  }

  Future<void> toggleOvulationAlert(bool value) async {
    await _updateNotifs(
      _settings!.notifications.copyWith(ovulationAlert: value),
    );
  }

  Future<void> togglePeriodEndAlert(bool value) async {
    await _updateNotifs(
      _settings!.notifications.copyWith(periodEndAlert: value),
    );
  }

  Future<void> _updateNotifs(NotificationSettings notifs) async {
    if (_settings == null) return;
    _settings = _settings!.copyWith(notifications: notifs);
    notifyListeners();
    await _repository.saveSettings(_settings!);
  }

  // ─────────────────────────────────────────────────────────────
  // Historique
  // ─────────────────────────────────────────────────────────────
  Future<void> deleteHistoryEntry(String id) async {
    await _repository.deleteHistoryEntry(id);
    final updated = _settings!.history.where((e) => e.id != id).toList();
    _settings = _settings!.copyWith(history: updated);
    notifyListeners();
  }

  Future<void> updateHistoryEntry(CycleHistoryEntry entry) async {
    await _repository.updateHistoryEntry(entry);
    final updated = _settings!.history
        .map((e) => e.id == entry.id ? entry : e)
        .toList();
    _settings = _settings!.copyWith(history: updated);
    notifyListeners();
  }

  void _setState(SettingsLoadState s) {
    _state = s;
    notifyListeners();
  }
}
