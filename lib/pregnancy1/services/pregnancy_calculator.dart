/// Service pour calculer les semaines de grossesse selon le standard médical obstétrical
/// Basé sur la date des dernières règles (LMP - Last Menstrual Period)
class PregnancyCalculator {
  /// Calcule le nombre total de jours écoulés depuis la date des dernières règles
  static int calculateTotalDaysElapsed(DateTime lastMenstrualPeriodDate) {
    final now = DateTime.now();
    return now.difference(lastMenstrualPeriodDate).inDays;
  }

  /// Calcule les semaines complètes écoulées
  /// Selon le standard médical : nombreDeJoursEcoules ÷ 7 (parties entières)
  static int calculateCompleteWeeks(DateTime lastMenstrualPeriodDate) {
    final totalDays = calculateTotalDaysElapsed(lastMenstrualPeriodDate);
    return (totalDays / 7).floor();
  }

  /// Calcule les jours supplémentaires dans la semaine actuelle
  /// nombreDeJoursEcoules % 7
  static int calculateDaysInCurrentWeek(DateTime lastMenstrualPeriodDate) {
    final totalDays = calculateTotalDaysElapsed(lastMenstrualPeriodDate);
    return totalDays % 7;
  }

  /// Retourne la semaine actuelle de grossesse (pour compatibilité API)
  /// Minimum 1 semaine, maximum 40 semaines
  /// Si 0-6 jours: semaine 1
  /// Si 7-13 jours: semaine 2, etc.
  static int calculateCurrentWeek(DateTime lastMenstrualPeriodDate) {
    final completeWeeks = calculateCompleteWeeks(lastMenstrualPeriodDate);
    final currentWeek = completeWeeks + 1;
    return currentWeek.clamp(1, 40);
  }

  /// Calcule le nombre de jours restants avant la date prévue d'accouchement (EDD)
  /// Selon le standard médical : EDD = LMP + 280 jours (40 semaines)
  static int calculateDaysRemaining(DateTime lastMenstrualPeriodDate) {
    final expectedDeliveryDate =
        lastMenstrualPeriodDate.add(const Duration(days: 280));
    final now = DateTime.now();
    final daysRemaining = expectedDeliveryDate.difference(now).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  /// Retourne la date prévue d'accouchement (EDD) selon le standard obstétrical
  /// EDD = LMP + 280 jours (40 semaines)
  static DateTime calculateExpectedDeliveryDate(
      DateTime lastMenstrualPeriodDate) {
    return lastMenstrualPeriodDate.add(const Duration(days: 280));
  }

  /// Détermine le trimestre basé sur la semaine de grossesse (standard médical)
  /// Trimestre 1: semaines 1-13
  /// Trimestre 2: semaines 14-27
  /// Trimestre 3: semaines 28-40
  static int calculateTrimester(int weekNumber) {
    if (weekNumber <= 13) return 1;
    if (weekNumber <= 27) return 2;
    return 3; // 28-40
  }

  /// Obtient le label du trimestre
  static String getTrimesterLabel(int weekNumber) {
    final trimester = calculateTrimester(weekNumber);
    switch (trimester) {
      case 1:
        return 'Premier trimestre';
      case 2:
        return 'Deuxième trimestre';
      case 3:
        return 'Troisième trimestre';
      default:
        return 'Trimestre inconnu';
    }
  }

  /// Valide et ajuste la semaine (minimum 1, maximum 40)
  static int validateWeekNumber(int weekNumber) {
    return weekNumber.clamp(1, 40);
  }

  /// Formate l'affichage de la semaine et des jours
  /// Format: "X semaines + Y jours"
  static String formatWeekDisplay(DateTime lastMenstrualPeriodDate) {
    final weeks = calculateCompleteWeeks(lastMenstrualPeriodDate);
    final days = calculateDaysInCurrentWeek(lastMenstrualPeriodDate);
    if (days == 0) {
      return '$weeks semaines';
    }
    return '$weeks semaines + $days jour${days > 1 ? 's' : ''}';
  }

  /// Récupère le numéro de semaine pour les requêtes API
  /// Utilisé pour récupérer les données de l'API (ex: semaine 19)
  static int getWeekNumberForAPI(DateTime lastMenstrualPeriodDate) {
    return calculateCurrentWeek(lastMenstrualPeriodDate);
  }

  /// Calcule la semaine basée sur la dernière date de règles (LMP)
  /// La grossesse est généralement comptée à partir du premier jour des dernières règles
  static int calculateWeekFromLMP(DateTime lastMenstrualPeriodDate) {
    return calculateCurrentWeek(lastMenstrualPeriodDate);
  }

  /// Calcule la date prévue d'accouchement à partir de la LMP
  static DateTime calculateEDDFromLMP(DateTime lastMenstrualPeriodDate) {
    // Par convention, on ajoute 280 jours à partir de la LMP
    return lastMenstrualPeriodDate.add(const Duration(days: 280));
  }
}
