
/// Utilitaires de dates pour l'application CycleApp
class CycleDateUtils {
  CycleDateUtils._(); // Classe non instanciable

  // ─────────────────────────────────────────────────────────────
  // Constantes
  // ─────────────────────────────────────────────────────────────

  static const List<String> _monthsFull = [
    '',
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  static const List<String> _monthsShort = [
    '',
    'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
    'juil', 'août', 'sep', 'oct', 'nov', 'déc',
  ];

  static const List<String> _daysFull = [
    '',
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];

  static const List<String> _daysShort = [
    '',
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim',
  ];

  static const List<String> _daysMin = [
    '',
    'L', 'M', 'M', 'J', 'V', 'S', 'D',
  ];

  // ─────────────────────────────────────────────────────────────
  // Formatage de dates
  // ─────────────────────────────────────────────────────────────

  /// "14 mai 2025"
  static String formatFull(DateTime date) {
    return '${date.day} ${_monthsShort[date.month]} ${date.year}';
  }

  /// "14 mai"
  static String formatShort(DateTime date) {
    return '${date.day} ${_monthsShort[date.month]}';
  }

  /// "Mai 2025"
  static String formatMonthYear(DateTime date) {
    return '${_monthsFull[date.month]} ${date.year}';
  }

  /// "Lundi 14 mai"
  static String formatDayMonthFull(DateTime date) {
    return '${_daysFull[date.weekday]} ${date.day} ${_monthsShort[date.month]}';
  }

  /// "Lun" / "Mar" ...
  static String formatDayShort(DateTime date) {
    return _daysShort[date.weekday];
  }

  /// "L" / "M" / "M" / "J" ...
  static String formatDayMin(DateTime date) {
    return _daysMin[date.weekday];
  }

  /// Nom du mois complet : "Janvier"
  static String monthName(int month) {
    assert(month >= 1 && month <= 12);
    return _monthsFull[month];
  }

  /// Nom du mois court : "jan"
  static String monthNameShort(int month) {
    assert(month >= 1 && month <= 12);
    return _monthsShort[month];
  }

  /// "Aujourd'hui" / "Hier" / "Lun 12 mai"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = dateOnly(now); // Corrigé : utilise la méthode locale au lieu de celle de Flutter
    final target = dateOnly(date); // Corrigé : idem
    final diff = target.difference(today).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == -1) return 'Hier';
    if (diff == 1) return 'Demain';
    if (diff > 1 && diff <= 6) return 'Dans $diff jours';
    if (diff < -1 && diff >= -6) return 'Il y a ${-diff} jours';
    return formatDayMonthFull(date);
  }

  /// "14:30" depuis un DateTime
  static String formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// "il y a 2h" / "il y a 5min" depuis un DateTime
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return formatShort(date);
  }

  // ─────────────────────────────────────────────────────────────
  // Comparaisons
  // ─────────────────────────────────────────────────────────────

  /// Vrai si deux dates sont le même jour (ignore l'heure)
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Vrai si la date est aujourd'hui
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Vrai si la date est hier
  static bool isYesterday(DateTime date) {
    return isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Vrai si la date est demain
  static bool isTomorrow(DateTime date) {
    return isSameDay(date, DateTime.now().add(const Duration(days: 1)));
  }

  /// Vrai si la date est dans le futur (après aujourd'hui)
  static bool isFuture(DateTime date) {
    final today = dateOnly(DateTime.now()); // Corrigé : évite le conflit SDK
    final target = dateOnly(date);
    return target.isAfter(today);
  }

  /// Vrai si la date est dans le passé (avant aujourd'hui)
  static bool isPast(DateTime date) {
    final today = dateOnly(DateTime.now()); // Corrigé : évite le conflit SDK
    final target = dateOnly(date);
    return target.isBefore(today);
  }

  /// Vrai si deux dates sont dans le même mois
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  // ─────────────────────────────────────────────────────────────
  // Navigation calendrier
  // ─────────────────────────────────────────────────────────────

  /// Date sans heure (minuit local pour éviter les décalages d'heure d'été/hiver)
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day).toLocal();
  }

  /// Premier jour du mois
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Dernier jour du mois
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Nombre de jours dans un mois
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Mois précédent
  static DateTime previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }

  /// Mois suivant
  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }

  /// Début de la semaine (lundi) contenant la date
  static DateTime startOfWeek(DateTime date) {
    return dateOnly(date).subtract(Duration(days: date.weekday - 1));
  }

  /// Fin de la semaine (dimanche) contenant la date
  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }

  /// Génère tous les jours du mois
  static List<DateTime> allDaysInMonth(DateTime month) {
    final count = daysInMonth(month.year, month.month);
    return List.generate(
      count,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  /// Génère N jours autour d'une date centrale (strip de dates)
  static List<DateTime> generateDayStrip({
    required DateTime center,
    int before = 7,
    int after = 7,
  }) {
    final total = before + after + 1;
    return List.generate(
      total,
      (i) => dateOnly(center).subtract(Duration(days: before - i)),
    );
  }

  /// Jours de la semaine en commençant par lundi
  static List<String> get weekDayHeaders => _daysShort.sublist(1);

  /// Offset du premier jour du mois (lundi=0, dimanche=6)
  static int firstWeekdayOffset(DateTime month) {
    return DateTime(month.year, month.month, 1).weekday - 1;
  }

  /// Nombre de semaines (lignes) à afficher pour un mois
  static int weeksInMonth(DateTime month) {
    final offset = firstWeekdayOffset(month);
    final days = daysInMonth(month.year, month.month);
    return ((offset + days) / 7).ceil();
  }

  // ─────────────────────────────────────────────────────────────
  // Calculs de différences
  // ─────────────────────────────────────────────────────────────

  /// Nombre de jours entre deux dates (valeur absolue)
  static int daysBetween(DateTime from, DateTime to) {
    final f = dateOnly(from);
    final t = dateOnly(to);
    return t.difference(f).inDays.abs();
  }

  /// Nombre de jours restants jusqu'à une date future
  static int daysUntil(DateTime target) {
    final today = dateOnly(DateTime.now());
    final t = dateOnly(target);
    final diff = t.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Nombre de jours depuis une date passée
  static int daysSince(DateTime past) {
    final today = dateOnly(DateTime.now());
    final p = dateOnly(past);
    final diff = today.difference(p).inDays;
    return diff < 0 ? 0 : diff;
  }

  // ─────────────────────────────────────────────────────────────
  // Clé unique pour Map / cache
  // ─────────────────────────────────────────────────────────────

  /// Clé de stockage : "2025-05-14"
  static String storageKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Reconstruit un DateTime depuis une clé "2025-05-14"
  static DateTime? fromStorageKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day).toLocal();
  }

  // ─────────────────────────────────────────────────────────────
  // Grille calendrier (pour MiniCalendarWidget)
  // ─────────────────────────────────────────────────────────────

  /// Retourne les cellules d'un calendrier mensuel.
  static List<DateTime?> calendarGrid(DateTime month) {
    final offset = firstWeekdayOffset(month);
    final days = allDaysInMonth(month);
    final grid = <DateTime?>[
      ...List.filled(offset, null),
      ...days,
    ];
    // Compléter jusqu'au multiple de 7
    while (grid.length % 7 != 0) {
      grid.add(null);
    }
    return grid;
  }
}