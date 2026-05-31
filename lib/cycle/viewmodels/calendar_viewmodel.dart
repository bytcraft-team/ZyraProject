import 'package:flutter/foundation.dart';
import '../data/models/calendar_model.dart';
import '../data/models/cycle_model.dart';
// Contient CyclePhase
import '../data/repositories/calendar_repository.dart';
import '../core/utils/date_utils.dart';

enum CalendarLoadState { idle, loading, success, error }

class CalendarViewModel extends ChangeNotifier {
  final CalendarRepository _repository;

  CalendarViewModel({required CalendarRepository repository})
      : _repository = repository;

  // ── State ────────────────────────────────────────────────────
  CalendarLoadState _state = CalendarLoadState.idle;
  CalendarLoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Mois affiché ─────────────────────────────────────────────
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime get currentMonth => _currentMonth;

  // ── Données ──────────────────────────────────────────────────
  CalendarMonth? _calendarMonth;
  CalendarMonth? get calendarMonth => _calendarMonth;

  CycleStats? _stats;
  CycleStats? get stats => _stats;

  List<TimelineSegment> _timeline = [];
  List<TimelineSegment> get timeline => _timeline;

  int _currentCycleDay = 1;
  int get currentCycleDay => _currentCycleDay;

  int _cycleDuration = 28;
  int get cycleDuration => _cycleDuration;

  CyclePhase _currentPhase = CyclePhase.luteal;
  CyclePhase get currentPhase => _currentPhase;

  // ── Computed ─────────────────────────────────────────────────
  String get monthLabel =>
      CycleDateUtils.formatMonthYear(_currentMonth);

  PhaseAdvice get currentAdvice =>
      PhaseAdvice.forPhase(_currentPhase);

  int get fertilityProbabilityPercent {
    switch (_currentPhase) {
      case CyclePhase.ovulation:
        return 96;
      case CyclePhase.fertile:
        return 82;
      case CyclePhase.luteal:
        return 44;
      case CyclePhase.rules:
        return 16;
    }
  }

  String get fertilityProbabilityLabel => '$fertilityProbabilityPercent%';

  String get fertilityProbabilitySummary {
    switch (_currentPhase) {
      case CyclePhase.ovulation:
        return 'Fertilité maximale';
      case CyclePhase.fertile:
        return 'Fenêtre fertile';
      case CyclePhase.luteal:
        return 'Énergie modérée';
      case CyclePhase.rules:
        return 'Basse fertilité';
    }
  }

  String get nextOvulationLabel {
    final cycleLength = _cycleDuration <= 0 ? 28 : _cycleDuration;
    final ovulationDay = _stats?.avgOvulationDay.round() ?? 14; // Sécurisé en int
    var diff = ovulationDay - _currentCycleDay;
    if (diff <= 0) {
      diff += cycleLength;
    }
    if (diff == 1) return 'Demain';
    if (diff == 0) return 'Aujourd’hui';
    return 'Dans $diff jours';
  }

  String get daysUntilPeriodLabel {
    final remaining = (_cycleDuration <= 0 ? 28 : _cycleDuration) - _currentCycleDay;
    if (remaining <= 0) return 'Aujourd’hui';
    if (remaining == 1) return 'Demain';
    return 'Dans $remaining jours';
  }

  String get cycleSmartMessage {
    switch (_currentPhase) {
      case CyclePhase.ovulation:
        return 'Ta fertilité est à son maximum. Énergie, confiance et connexion sont en hausse.';
      case CyclePhase.fertile:
        return 'Tu es dans une phase vivante. Profite de ton élan, de ta créativité et de ton humeur lumineuse.';
      case CyclePhase.luteal:
        return 'Ton corps se prépare à une potentielle nouvelle phase. Privilégie le confort, la nutrition et la détente.';
      case CyclePhase.rules:
        return 'Douceur et repos sont recommandés. Écoute ton corps, hydrate-toi et garde une routine apaisante.';
    }
  }

  double get cycleProgress => timelineCursorPosition;

  double get timelineCursorPosition {
    if (_cycleDuration == 0) return 0;
    return ((_currentCycleDay - 1) / _cycleDuration).clamp(0.0, 1.0);
  }

  // ─────────────────────────────────────────────────────────────
  // Init — charge tout
  // ─────────────────────────────────────────────────────────────
  Future<void> init() async {
    _setState(CalendarLoadState.loading);
    _errorMessage = null;

    try {
      // 1. Récupérer les statistiques
      _stats = await _repository.getCycleStats();
      
      // Correction de type : On force la conversion du 'num' ou du 'double' en 'int' avec .round()
      _cycleDuration = _stats?.avgCycleDuration.round() ?? 28;

      // 2. Charger le reste des éléments graphiques synchronisés
      final results = await Future.wait([
        _repository.getCalendarMonth(_currentMonth),
        _repository.getTimelineSegments(_cycleDuration),
      ]);

      _calendarMonth = results[0] as CalendarMonth;
      _timeline      = results[1] as List<TimelineSegment>;

      await _computeCurrentDayInfo();
      _setState(CalendarLoadState.success);
    } catch (e, stack) {
      debugPrint('CalendarVM.init error: $e\n$stack');
      _errorMessage = 'Impossible de charger le calendrier';
      _setState(CalendarLoadState.error);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Calcul du jour et de la phase courants
  // ─────────────────────────────────────────────────────────────
  Future<void> _computeCurrentDayInfo() async {
    final now = DateTime.now();

    if (_calendarMonth != null) {
      try {
        final todayEntry = _calendarMonth!.days.firstWhere(
          (d) => CycleDateUtils.isSameDay(d.date, now),
        );
        _currentCycleDay = todayEntry.dayInCycle;
        _currentPhase    = todayEntry.phase;
        return;
      } catch (_) {
        // "Aujourd'hui" n'est pas dans le mois affiché à l'écran
      }
    }

    try {
      final todayDetail = await _repository.getDayDetail(now);
      _currentCycleDay = todayDetail.dayInCycle;
      _currentPhase    = todayDetail.phase;
    } catch (e) {
      debugPrint('Erreur lors du calcul des informations du jour J : $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Navigation mois
  // ─────────────────────────────────────────────────────────────
  Future<void> previousMonth() async {
    _currentMonth = CycleDateUtils.previousMonth(_currentMonth);
    await _reloadMonth();
  }

  Future<void> nextMonth() async {
    _currentMonth = CycleDateUtils.nextMonth(_currentMonth);
    await _reloadMonth();
  }

  Future<void> _reloadMonth() async {
    _calendarMonth = null;
    notifyListeners();

    try {
      _calendarMonth = await _repository.getCalendarMonth(_currentMonth);
      await _computeCurrentDayInfo();
      notifyListeners();
    } catch (e) {
      debugPrint('CalendarVM._reloadMonth error: $e');
      _errorMessage = 'Erreur lors du chargement du mois';
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Détail d'un jour
  // ─────────────────────────────────────────────────────────────
  Future<CalendarDay> getDayDetail(DateTime date) {
    return _repository.getDayDetail(date);
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────
  void _setState(CalendarLoadState s) {
    _state = s;
    notifyListeners();
  }
}