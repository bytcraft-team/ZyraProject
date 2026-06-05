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
    this.dureeCycle = 28,
    this.dureeRegles = 5,
    required this.derniereRegles,
    this.modeGrossesse = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
 
  // ── Calculs automatiques ─────────────────────────────────
  DateTime get prochaineRegles =>
      derniereRegles.add(Duration(days: dureeCycle));
 
  DateTime get dateOvulation =>
      derniereRegles.add(Duration(days: dureeCycle - 14));
 
  DateTime get debutFertile =>
      dateOvulation.subtract(const Duration(days: 5));
 
  DateTime get finFertile =>
      dateOvulation.add(const Duration(days: 1));
 
  int get joursAvantRegles =>
      prochaineRegles.difference(DateTime.now()).inDays;
 
  bool estJourRegles(DateTime date) {
    final diff = date.difference(derniereRegles).inDays;
    return diff >= 0 && diff < dureeRegles;
  }
 
  bool estJourFertile(DateTime date) {
    return date.isAfter(debutFertile.subtract(const Duration(days: 1))) &&
        date.isBefore(finFertile.add(const Duration(days: 1)));
  }
 
  bool estJourOvulation(DateTime date) {
    return date.year == dateOvulation.year &&
        date.month == dateOvulation.month &&
        date.day == dateOvulation.day;
  }
 
  // ── SQLite ───────────────────────────────────────────────
  factory CycleModel.fromMap(Map<String, dynamic> map) {
    return CycleModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      dureeCycle: map['duree_cycle'] as int,
      dureeRegles: map['duree_regles'] as int,
      derniereRegles: DateTime.parse(map['derniere_regles'] as String),
      modeGrossesse: (map['mode_grossesse'] as int) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
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
 
  // ── Firestore ────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'duree_cycle': dureeCycle,
      'duree_regles': dureeRegles,
      'derniere_regles': derniereRegles.toIso8601String(),
      'mode_grossesse': modeGrossesse,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
 
  CycleModel copyWith({
    int? id,
    String? userId,
    int? dureeCycle,
    int? dureeRegles,
    DateTime? derniereRegles,
    bool? modeGrossesse,
  }) {
    return CycleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dureeCycle: dureeCycle ?? this.dureeCycle,
      dureeRegles: dureeRegles ?? this.dureeRegles,
      derniereRegles: derniereRegles ?? this.derniereRegles,
      modeGrossesse: modeGrossesse ?? this.modeGrossesse,
    );
  }
}