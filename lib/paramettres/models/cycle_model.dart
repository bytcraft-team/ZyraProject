class CycleModel {
  final int? id;
  final String userId;
  final int dureeCycle;
  final int dureeRegles;
  final DateTime derniereRegles;
  final bool modeGrossesse;
  final DateTime updatedAt;

  CycleModel({
    this.id,
    required this.userId,
    required this.dureeCycle,
    required this.dureeRegles,
    required this.derniereRegles,
    required this.modeGrossesse,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  CycleModel copyWith({
    int? id,
    String? userId,
    int? dureeCycle,
    int? dureeRegles,
    DateTime? derniereRegles,
    bool? modeGrossesse,
    DateTime? updatedAt,
  }) {
    return CycleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dureeCycle: dureeCycle ?? this.dureeCycle,
      dureeRegles: dureeRegles ?? this.dureeRegles,
      derniereRegles: derniereRegles ?? this.derniereRegles,
      modeGrossesse: modeGrossesse ?? this.modeGrossesse,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'duree_cycle': dureeCycle,
      'duree_regles': dureeRegles,
      'derniere_regles': derniereRegles.toIso8601String(),
      'mode_grossesse': modeGrossesse ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CycleModel.fromMap(Map<String, dynamic> map) {
    return CycleModel(
      id: map['id'] is int
          ? map['id'] as int
          : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      userId: map['user_id'] as String? ?? map['userId'] as String? ?? '',
      dureeCycle: (map['duree_cycle'] is int)
          ? map['duree_cycle'] as int
          : int.tryParse(map['duree_cycle'].toString()) ?? 28,
      dureeRegles: (map['duree_regles'] is int)
          ? map['duree_regles'] as int
          : int.tryParse(map['duree_regles'].toString()) ?? 5,
      derniereRegles: map['derniere_regles'] is String
          ? DateTime.parse(map['derniere_regles'] as String)
          : (map['derniere_regles'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['derniere_regles'] as int)
              : DateTime.now()),
      modeGrossesse: (map['mode_grossesse'] == 1 ||
          map['mode_grossesse'] == true ||
          map['mode_grossesse'] == 'true'),
      updatedAt: map['updated_at'] is String
          ? DateTime.parse(map['updated_at'] as String)
          : (map['updated_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'duree_cycle': dureeCycle,
      'duree_regles': dureeRegles,
      'derniere_regles': derniereRegles.toIso8601String(),
      'mode_grossesse': modeGrossesse,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// ====================== Calculs du cycle ======================
extension CycleCalculations on CycleModel {
  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  // Compute most recent cycle start (the cycle that contains today)
  DateTime _cycleStartFor(DateTime reference) {
    final ref = _startOfDay(reference);
    final last = _startOfDay(derniereRegles);
    final days = ref.difference(last).inDays;
    final cycles = days >= 0 ? days ~/ dureeCycle : -(((-days) + dureeCycle - 1) ~/ dureeCycle);
    return last.add(Duration(days: cycles * dureeCycle));
  }

  // Next period start after reference (usually now)
  DateTime prochaineReglesFrom(DateTime reference) {
    final start = _cycleStartFor(reference);
    final next = start.add(Duration(days: dureeCycle));
    if (!next.isAfter(reference)) return next.add(Duration(days: dureeCycle));
    return next;
  }

  DateTime get prochaineRegles => prochaineReglesFrom(DateTime.now());

  int get joursAvantRegles {
    final now = _startOfDay(DateTime.now());
    final next = _startOfDay(prochaineRegles);
    return next.difference(now).inDays;
  }

  // Approximate ovulation: typically ~14 days before next period
  DateTime dateOvulationFrom(DateTime reference) {
    final start = _cycleStartFor(reference);
    final ovulationIndex = (dureeCycle - 14) >= 0 ? (dureeCycle - 14) : (dureeCycle ~/ 2);
    DateTime ov = start.add(Duration(days: ovulationIndex));
    if (!ov.isAfter(reference)) ov = ov.add(Duration(days: dureeCycle));
    return ov;
  }

  DateTime get dateOvulation => dateOvulationFrom(DateTime.now());

  bool estJourRegles(DateTime date) {
    final start = _cycleStartFor(date);
    final diff = _startOfDay(date).difference(start).inDays;
    return diff >= 0 && diff < dureeRegles;
  }

  bool estJourOvulation(DateTime date) {
    final ov = _startOfDay(dateOvulationFrom(date));
    return _startOfDay(date).difference(ov).inDays == 0;
  }

  bool estJourFertile(DateTime date) {
    final ov = _startOfDay(dateOvulationFrom(date));
    final d = _startOfDay(date).difference(ov).inDays;
    // fertile window: 5 days before ovulation up to ovulation day
    return d <= 0 && d >= -5;
  }
}

