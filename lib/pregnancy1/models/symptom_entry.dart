class SymptomEntry {
  final String id;
  final String label;
  final double intensity;

  SymptomEntry({
    required this.id,
    required this.label,
    required this.intensity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'intensity': intensity,
    };
  }

  factory SymptomEntry.fromMap(Map<String, dynamic> map) {
    return SymptomEntry(
      id: map['id'],
      label: map['label'],
      intensity: (map['intensity'] as num).toDouble(),
    );
  }
}