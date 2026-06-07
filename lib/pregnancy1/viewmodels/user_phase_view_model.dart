/*import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:zyra/cycle1/data/models/cycle_model.dart';
import 'package:zyra/cycle1/data/repositories/cycle_repository.dart';
import 'package:zyra/cycle1/data/repositories/settings_repository.dart';
import 'package:zyra/pregnancy1/repositories/user_repository.dart';
import 'package:zyra/models/user_phase.dart';

class UserPhaseViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final CycleRepository _cycleRepository;
  final SettingsRepository _settingsRepository;

  UserPhase? _currentPhase;
  DateTime? _pregnancyStartDate;
  DateTime? _deliveryDate;
  DateTime? _firstPeriodAfterBirth;
  bool _isLoading = true;
  String? _errorMessage;

  UserPhaseViewModel({
    UserRepository? userRepository,
    CycleRepository? cycleRepository,
    SettingsRepository? settingsRepository,
  })  : _userRepository = userRepository ?? UserRepository(),
        _cycleRepository = cycleRepository ?? CycleRepositoryImpl(),
        _settingsRepository = settingsRepository ?? SettingsRepositoryImpl();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserPhase get currentPhase => _currentPhase ?? UserPhase.menstrualCycle;
  DateTime? get pregnancyStartDate => _pregnancyStartDate;
  DateTime? get deliveryDate => _deliveryDate;
  DateTime? get firstPeriodAfterBirth => _firstPeriodAfterBirth;

  Future<void> loadPhase() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _userRepository.loadCurrentUserProfile();
      final phaseValue = profile?['user_phase'] as String?;
      _currentPhase = (phaseValue ?? 'menstrualCycle').toUserPhase();
      _pregnancyStartDate = _parseDate(profile?['pregnancy_start_date']);
      _deliveryDate = _parseDate(profile?['delivery_date']);
      _firstPeriodAfterBirth = _parseDate(profile?['first_period_after_birth']);
    } catch (e) {
      _errorMessage = 'Impossible de charger l\'état utilisateur: $e';
      debugPrint(_errorMessage);
      _currentPhase = UserPhase.menstrualCycle;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  Future<void> startPregnancy(DateTime lastMenstrualPeriod) async {
    if (currentPhase != UserPhase.menstrualCycle) {
      throw StateError('Le passage à la grossesse ne peut être déclenché que depuis le cycle menstruel.');
    }

    final dueDate = _userRepository.computeExpectedDueDate(lastMenstrualPeriod);
    await _userRepository.startPregnancy(lastMenstrualPeriod, dueDate);

    _currentPhase = UserPhase.pregnant;
    _pregnancyStartDate = lastMenstrualPeriod;
    _deliveryDate = dueDate;
    _firstPeriodAfterBirth = null;
    notifyListeners();
  }

  Future<void> finishPregnancy(DateTime deliveryDate) async {
    if (currentPhase != UserPhase.pregnant) {
      throw StateError('L\'accouchement ne peut être déclaré qu\'en grossesse.');
    }

    await _userRepository.finishPregnancy(deliveryDate);
    _currentPhase = UserPhase.postpartum;
    _deliveryDate = deliveryDate;
    notifyListeners();
  }

  Future<void> recordFirstPeriodAfterBirth(DateTime firstPeriodDate) async {
    if (currentPhase != UserPhase.postpartum) {
      throw StateError('Le retour des règles ne peut être enregistré que pendant le postpartum.');
    }

    if (_deliveryDate != null && !firstPeriodDate.isAfter(_deliveryDate!)) {
      throw ArgumentError('La date des règles doit être postérieure à la date d\'accouchement.');
    }

    final settings = await _settingsRepository.getSettings();
    final cycleDuration = settings.cycleDuration;
    final periodDuration = settings.periodDuration;
    final predictedOvulation = firstPeriodDate.add(Duration(days: cycleDuration - 14));
    final predictedFertilityStart = predictedOvulation.subtract(const Duration(days: 5));
    final predictedFertilityEnd = predictedOvulation.add(const Duration(days: 1));

    final newCycle = CycleModel(
      id: const Uuid().v4(),
      startDate: firstPeriodDate,
      endDate: null,
      predictedOvulation: predictedOvulation,
      predictedFertilityStart: predictedFertilityStart,
      predictedFertilityEnd: predictedFertilityEnd,
      cycleDuration: cycleDuration,
      expectedPeriodDuration: periodDuration,
      regularity: settings.regularity,
      lastUpdated: DateTime.now(),
      isSynced: 0,
    );

    await _cycleRepository.saveCycle(newCycle);
    await _userRepository.completePostpartumReturn(firstPeriodDate);

    _currentPhase = UserPhase.menstrualCycle;
    _firstPeriodAfterBirth = firstPeriodDate;
    notifyListeners();
  }
}
*/