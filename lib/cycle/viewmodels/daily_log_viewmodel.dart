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

  // ── Champs du formulaire ─────────────────────────────────────
  FlowIntensity? _flowIntensity;
  FlowIntensity? get flowIntensity => _flowIntensity;

  List<SymptomEntry> _symptoms = [];
  List<SymptomEntry> get symptoms => List.unmodifiable(_symptoms);

  List<MoodType> _moods = [];
  List<MoodType> get moods => List.unmodifiable(_moods);

  double _basalTemperature = 36.5;
  double get basalTemperature => _basalTemperature;

  CervicalMucusType? _cervicalMucus;
  CervicalMucusType? get cervicalMucus => _cervicalMucus;

  String _notes = '';
  String get notes => _notes;

  List<NoteMedia> _medias = [];
  List<NoteMedia> get medias => List.unmodifiable(_medias);

  bool _showAllSymptoms = false;
  bool get showAllSymptoms => _showAllSymptoms;

  // ── Computed ─────────────────────────────────────────────────
  bool get hasTemperatureWarning => _basalTemperature >= 37.0;

  String get temperatureWarningMessage =>
      '🌡️ Température élevée — possible ovulation détectée';

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
    _buildWeekDays(DateTime.now());
    await _loadWeekData();
    await _loadForDate(_selectedDate);
  }

  // ── Init depuis un jour spécifique (DayDetail → DailyLog) ────
  Future<void> initWithDate(DateTime date) async {
    _selectedDate = CycleDateUtils.dateOnly(date);
    _buildWeekDays(date);
    await _loadWeekData();
    await _loadForDate(_selectedDate);
  }

  void _buildWeekDays(DateTime center) {
    _weekDays = List.generate(
      14,
      (i) => CycleDateUtils.dateOnly(center).subtract(Duration(days: 7 - i)),
    );
    notifyListeners();
  }

  Future<void> _loadWeekData() async {
    if (_weekDays.isEmpty) return;
    final result = await _repository.getWeekHasData(_weekDays.first);
    _weekHasData = result.map(
      (k, v) => MapEntry(CycleDateUtils.storageKey(k), v),
    );
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = CycleDateUtils.dateOnly(date);
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
    } else {
      _resetForm();
    }
    _isLoading = false;
    notifyListeners();
  }

  void _applyLog(DailyLogModel log) {
    _flowIntensity = log.flowIntensity;
    _symptoms = List<SymptomEntry>.from(log.symptoms);
    _moods = List<MoodType>.from(log.moods);
    _basalTemperature = log.basalTemperature ?? 36.5;
    _cervicalMucus = log.cervicalMucus;
    _notes = log.notes ?? '';
    _medias = List<NoteMedia>.from(log.medias);
  }

  void _resetForm() {
    _flowIntensity = null;
    _symptoms = <SymptomEntry>[];
    _moods = <MoodType>[];
    _basalTemperature = 36.5;
    _cervicalMucus = null;
    _notes = '';
    _medias = <NoteMedia>[];
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
    _basalTemperature = double.parse(
        (_basalTemperature + 0.1).toStringAsFixed(1));
    if (_basalTemperature > 42.0) _basalTemperature = 42.0;
    notifyListeners();
  }

  void decreaseTemperature() {
    _basalTemperature = double.parse(
        (_basalTemperature - 0.1).toStringAsFixed(1));
    if (_basalTemperature < 35.0) _basalTemperature = 35.0;
    notifyListeners();
  }

  void selectCervicalMucus(CervicalMucusType type) {
    _cervicalMucus = _cervicalMucus == type ? null : type;
    notifyListeners();
  }

  void updateNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  void addMedia(NoteMedia media) {
    final currentMedias = List<NoteMedia>.from(_medias);
    currentMedias.add(media);
    _medias = currentMedias;
    notifyListeners();
  }

  void removeMedia(int index) {
    final currentMedias = List<NoteMedia>.from(_medias);
    if (index >= 0 && index < currentMedias.length) {
      currentMedias.removeAt(index);
      _medias = currentMedias;
      notifyListeners();
    }
  }

  // ── Save ─────────────────────────────────────────────────────
  Future<bool> saveLog() async {
    _saveState = SaveState.saving;
    notifyListeners();

    try {
      final log = DailyLogModel(
        date: _selectedDate,
        flowIntensity: _flowIntensity,
        symptoms: List.from(_symptoms),
        moods: List.from(_moods),
        basalTemperature: _basalTemperature,
        cervicalMucus: _cervicalMucus,
        notes: _notes.isEmpty ? null : _notes,
        medias: List.from(_medias),
        hasData: true,
      );

      await _repository.saveLog(log);

      // Mettre à jour la carte d'activité de la semaine
      _weekHasData[CycleDateUtils.storageKey(_selectedDate)] = true;

      _saveState = SaveState.success;
      notifyListeners();
      return true;
    } catch (_) {
      _saveState = SaveState.error;
      notifyListeners();
      return false;
    }
  }

  // Remettre à zéro le saveState
  void resetSaveState() {
    _saveState = SaveState.idle;
    notifyListeners();
  }
}