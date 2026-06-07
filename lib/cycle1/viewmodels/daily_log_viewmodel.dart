import 'dart:async';

import 'package:flutter/foundation.dart';
import '../data/models/daily_log_model.dart';
// Pour l'accès aux énumérations partagées
import '../data/repositories/daily_log_repository.dart';
import '../core/utils/date_utils.dart';

enum SaveState { idle, saving, success, error }

class DailyLogViewModel extends ChangeNotifier {
  final DailyLogRepository _repository;

  DailyLogViewModel({required DailyLogRepository repository})
      : _repository = repository;

  // ── State ────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SaveState _saveState = SaveState.idle;
  SaveState get saveState => _saveState;

  // ── Date sélectionnée ────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // ── Strip de dates ───────────────────────────────────────────
  List<DateTime> _weekDays = [];
  List<DateTime> get weekDays => _weekDays;

  Map<String, bool> _weekHasData = {};

  bool hasDataForDay(DateTime date) {
    return _weekHasData[CycleDateUtils.storageKey(date)] ?? false;
  }

  DailyLogModel? _currentLog;
  DailyLogModel? get currentLog => _currentLog;

  DailyLogModel? getJournalByDate(DateTime date) {
    if (CycleDateUtils.dateOnly(date) != CycleDateUtils.dateOnly(_selectedDate)) {
      return null;
    }
    return _currentLog;
  }

  Timer? _saveStateResetTimer;

  void _setSaveState(SaveState state, {Duration? resetAfter}) {
    _saveStateResetTimer?.cancel();
    _saveState = state;
    notifyListeners();
    if (resetAfter != null) {
      _saveStateResetTimer = Timer(resetAfter, () {
        if (_saveState == state) {
          _saveState = SaveState.idle;
          notifyListeners();
        }
      });
    }
  }

  List<DailyLogModel> _historyLogs = [];
  List<DailyLogModel> get historyLogs => List.unmodifiable(_historyLogs);

  // ── Champs du formulaire ─────────────────────────────────────
  FlowIntensity? _flowIntensity;
  FlowIntensity? get flowIntensity => _flowIntensity;

  List<SymptomEntry> _symptoms = [];
  List<SymptomEntry> get symptoms => List.unmodifiable(_symptoms);

  List<MoodType> _moods = [];
  List<MoodType> get moods => List.unmodifiable(_moods);


  CervicalMucusType? _cervicalMucus;
  CervicalMucusType? get cervicalMucus => _cervicalMucus;

  String? _note;
  String? get note => _note;

  bool _showAllSymptoms = false;
  bool get showAllSymptoms => _showAllSymptoms;

  // ── Computed ─────────────────────────────────────────────────
  

  bool isSymptomSelected(SymptomType type) =>
      _symptoms.any((s) => s.type == type);

  int symptomIntensity(SymptomType type) {
    try {
      return _symptoms.firstWhere((s) => s.type == type).intensity;
    } catch (_) {
      return 1;
    }
  }

  bool isMoodSelected(MoodType mood) => _moods.contains(mood);

  List<SymptomType> get visibleSymptoms {
    if (_showAllSymptoms) {
      return [...SymptomTypeExt.defaults, ...SymptomTypeExt.extras];
    }
    return SymptomTypeExt.defaults;
  }

  // ── Init global (onglet Journal) ─────────────────────────────
  Future<void> init() async {
    generateDaysFromToday();
    await _loadWeekData();
    await _loadForDate(_selectedDate);
  }

  // ── Init depuis un jour spécifique (DayDetail → DailyLog) ────
  Future<void> initWithDate(DateTime date) async {
    _selectedDate = CycleDateUtils.dateOnly(date);
    // Keep a dynamic window ending on the selected date if needed
    generateDaysFromToday();
    await _loadWeekData();
    await _loadForDate(_selectedDate);
  }

  /// Generate a list of days ending today (oldest -> newest).
  ///
  /// `limit` controls how many days to keep (default 30). The list is ordered
  /// from oldest (index 0) to newest (last index = today).
  void generateDaysFromToday({int limit = 30}) {
    final today = CycleDateUtils.dateOnly(DateTime.now());
    _weekDays = List.generate(
      limit,
      (i) => CycleDateUtils.dateOnly(today.subtract(Duration(days: limit - 1 - i))),
    );
    notifyListeners();
  }

  /// Generate days ending on [end] (oldest -> newest). Useful to ensure a
  /// selected date is within the visible window.
  void generateDaysEndingOn(DateTime end, {int limit = 30}) {
    final last = CycleDateUtils.dateOnly(end);
    _weekDays = List.generate(
      limit,
      (i) => CycleDateUtils.dateOnly(last.subtract(Duration(days: limit - 1 - i))),
    );
    notifyListeners();
  }

  void _refreshDaysIfNeeded({int limit = 30}) {
    final today = CycleDateUtils.dateOnly(DateTime.now());
    if (_weekDays.isEmpty || CycleDateUtils.dateOnly(_weekDays.last) != today) {
      generateDaysFromToday(limit: limit);
    }
  }

  Future<void> _loadWeekData() async {
    if (_weekDays.isEmpty) return;
    final result = await _repository.getWeekHasData(_weekDays.first);
    _weekHasData = result.map(
      (k, v) => MapEntry(CycleDateUtils.storageKey(k), v),
    );
    await _refreshHistory();
    notifyListeners();
  }

  Future<void> _refreshHistory() async {
    if (_weekDays.isEmpty) return;
    final start = _weekDays.first;
    final end = _weekDays.last;
    final logs = await _repository.getLogsForRange(start, end);
    _historyLogs = List<DailyLogModel>.from(logs);
    _historyLogs.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = CycleDateUtils.dateOnly(date);
    // Ensure the selected date is within the current window; if not, rebuild
    // the days window to end on the selected date so it becomes visible.
    if (_weekDays.isEmpty || _selectedDate.isBefore(_weekDays.first) || _selectedDate.isAfter(_weekDays.last)) {
      generateDaysEndingOn(_selectedDate);
    } else {
      _refreshDaysIfNeeded();
    }
    _resetForm();
    notifyListeners();
    await _loadForDate(_selectedDate);
  }

  Future<void> _loadForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();
    final log = await _repository.getLogForDate(date);
    if (log != null) {
      _applyLog(log);
      _currentLog = log;
    } else {
      _currentLog = null;
      _resetForm();
    }
    _isLoading = false;
    notifyListeners();
  }

  void _applyLog(DailyLogModel log) {
    _flowIntensity = log.flowIntensity;
    _symptoms = List<SymptomEntry>.from(log.symptoms);
    _moods = List<MoodType>.from(log.moods);
    _cervicalMucus = log.cervicalMucus;
    _note = log.notes.isNotEmpty ? log.notes.first : null;
  }

  void _resetForm() {
    _flowIntensity = null;
    _symptoms = <SymptomEntry>[];
    _moods = <MoodType>[];
    _cervicalMucus = null;
    _note = null;
  }

  Future<bool> deleteCurrentLog() async {
    if (_currentLog == null) return false;
    return deleteLogByDate(_selectedDate);
  }

  Future<bool> deleteLogByDate(DateTime date) async {
    _setSaveState(SaveState.saving);

    try {
      await _repository.deleteLogForDate(date);
      _weekHasData.remove(CycleDateUtils.storageKey(date));
      await _refreshHistory();

      if (CycleDateUtils.dateOnly(_selectedDate) == CycleDateUtils.dateOnly(date)) {
        _currentLog = null;
        _resetForm();
      }

      _setSaveState(SaveState.success, resetAfter: const Duration(milliseconds: 700));
      return true;
    } catch (_) {
      _setSaveState(SaveState.error, resetAfter: const Duration(seconds: 1));
      return false;
    }
  }

  // ── Actions formulaire ───────────────────────────────────────
  void selectFlow(FlowIntensity intensity) {
    _flowIntensity = _flowIntensity == intensity ? null : intensity;
    notifyListeners();
  }

  void toggleSymptom(SymptomType type) {
    // Création d'une copie éditable de la liste pour contourner l'immuabilité
    final currentSymptoms = List<SymptomEntry>.from(_symptoms);
    final idx = currentSymptoms.indexWhere((s) => s.type == type);
    
    if (idx >= 0) {
      currentSymptoms.removeAt(idx);
    } else {
      currentSymptoms.add(SymptomEntry(type: type, intensity: 1));
    }
    
    _symptoms = currentSymptoms;
    notifyListeners();
  }

  void setSymptomIntensity(SymptomType type, int intensity) {
    final currentSymptoms = List<SymptomEntry>.from(_symptoms);
    final idx = currentSymptoms.indexWhere((s) => s.type == type);
    
    if (idx >= 0) {
      currentSymptoms[idx] = currentSymptoms[idx].copyWith(intensity: intensity);
    } else {
      currentSymptoms.add(SymptomEntry(type: type, intensity: intensity));
    }
    
    _symptoms = currentSymptoms;
    notifyListeners();
  }

  void toggleShowAllSymptoms() {
    _showAllSymptoms = !_showAllSymptoms;
    notifyListeners();
  }

  void toggleMood(MoodType mood) {
    final currentMoods = List<MoodType>.from(_moods);
    
    if (currentMoods.contains(mood)) {
      currentMoods.remove(mood);
    } else {
      currentMoods.add(mood);
    }
    
    _moods = currentMoods;
    notifyListeners();
  }

  void increaseTemperature() {
    // temperature tracking removed
  }

  void decreaseTemperature() {
    // temperature tracking removed
  }

  void selectCervicalMucus(CervicalMucusType type) {
    _cervicalMucus = _cervicalMucus == type ? null : type;
    notifyListeners();
  }

  void saveNote(String note) {
    final trimmed = note.trim();
    _note = trimmed.isEmpty ? null : trimmed;
    notifyListeners();
  }

  // ── Save ─────────────────────────────────────────────────────
  Future<bool> saveLog() async {
    _setSaveState(SaveState.saving);

    try {
      final log = DailyLogModel(
        date: _selectedDate,
        flowIntensity: _flowIntensity,
        symptoms: List.from(_symptoms),
        moods: List.from(_moods),
        cervicalMucus: _cervicalMucus,
        notes: _note != null ? <String>[_note!] : const [],
        hasData: true,
      );

      await _repository.saveLog(log);
      _currentLog = log;
      _weekHasData[CycleDateUtils.storageKey(_selectedDate)] = true;
      // Refresh days/historical list and data after upsert
      _refreshDaysIfNeeded();
      await _refreshHistory();

      _setSaveState(SaveState.success, resetAfter: const Duration(milliseconds: 700));
      return true;
    } catch (_) {
      _setSaveState(SaveState.error, resetAfter: const Duration(seconds: 1));
      return false;
    }
  }

  // Remettre à zéro le saveState
  void resetSaveState() {
    _setSaveState(SaveState.idle);
  }

  @override
  void dispose() {
    _saveStateResetTimer?.cancel();
    super.dispose();
  }
}