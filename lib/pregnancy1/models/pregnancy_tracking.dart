/// Modèle pour stocker les données de suivi de grossesse
/// Basé sur le standard médical (LMP - Last Menstrual Period)
class PregnancyTracking {
  final DateTime pregnancyStartDate; // Date des dernières règles (LMP)
  final int currentWeek;
  final int daysInCurrentWeek; // Jours supplémentaires dans la semaine actuelle
  final int daysRemaining;
  final int trimester;
  final DateTime expectedDeliveryDate;
  final DateTime lastCalculatedAt;

  PregnancyTracking({
    required this.pregnancyStartDate,
    required this.currentWeek,
    required this.daysInCurrentWeek,
    required this.daysRemaining,
    required this.trimester,
    required this.expectedDeliveryDate,
    DateTime? lastCalculatedAt,
  }) : lastCalculatedAt = lastCalculatedAt ?? DateTime.now();

  /// Retourne l'affichage formaté de la semaine
  /// Format: "X semaines + Y jours"
  String get weekDisplay {
    if (daysInCurrentWeek == 0) {
      return '$currentWeek semaines';
    }
    return '$currentWeek semaines + $daysInCurrentWeek jour${daysInCurrentWeek > 1 ? 's' : ''}';
  }

  /// Convertit en Map pour Firestore
  /// Attention: On ne sauvegarde que la date LMP, pas les semaines calculées
  /// Les semaines seront recalculées à chaque ouverture de l'application
  Map<String, dynamic> toFirestore() {
    return {
      'pregnancyStartDate': pregnancyStartDate.toIso8601String(),
      // currentWeek, daysInCurrentWeek, daysRemaining, etc. NE sont PAS sauvegardés
      // Ils sont recalculés dynamiquement à chaque ouverture
      'lastCalculatedAt': lastCalculatedAt.toIso8601String(),
    };
  }

  /// Crée une instance à partir des données Firestore
  factory PregnancyTracking.fromFirestore(Map<String, dynamic> data) {
    // Récupère la date LMP depuis Firestore
    final pregnancyStartDate = DateTime.parse(
        data['pregnancyStartDate'] as String? ??
            DateTime.now().toIso8601String());

    // Recalcule tous les paramètres basés sur la date LMP
    final now = DateTime.now();
    final totalDays = now.difference(pregnancyStartDate).inDays;
    final completeWeeks = (totalDays / 7).floor();
    final currentWeek = (completeWeeks + 1).clamp(1, 40);
    final daysInCurrentWeek = totalDays % 7;
    final expectedDeliveryDate =
        pregnancyStartDate.add(const Duration(days: 280));
    final daysRemaining = expectedDeliveryDate.difference(now).inDays;
    final trimester = currentWeek <= 13 ? 1 : (currentWeek <= 27 ? 2 : 3);

    return PregnancyTracking(
      pregnancyStartDate: pregnancyStartDate,
      currentWeek: currentWeek,
      daysInCurrentWeek: daysInCurrentWeek,
      daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
      trimester: trimester,
      expectedDeliveryDate: expectedDeliveryDate,
      lastCalculatedAt: data['lastCalculatedAt'] != null
          ? DateTime.parse(data['lastCalculatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Crée une copie avec certains champs modifiés
  PregnancyTracking copyWith({
    DateTime? pregnancyStartDate,
    int? currentWeek,
    int? daysInCurrentWeek,
    int? daysRemaining,
    int? trimester,
    DateTime? expectedDeliveryDate,
    DateTime? lastCalculatedAt,
  }) {
    return PregnancyTracking(
      pregnancyStartDate: pregnancyStartDate ?? this.pregnancyStartDate,
      currentWeek: currentWeek ?? this.currentWeek,
      daysInCurrentWeek: daysInCurrentWeek ?? this.daysInCurrentWeek,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      trimester: trimester ?? this.trimester,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      lastCalculatedAt: lastCalculatedAt ?? this.lastCalculatedAt,
    );
  }
}
