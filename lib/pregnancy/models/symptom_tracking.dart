import 'symptom_entry.dart';

class SymptomTrackingModel {
  final String id;
  final String userId;
  final DateTime date;
  final int moodIndex;
  final String moodLabel;
  final String notes;
  final List<SymptomEntry> symptoms;

  SymptomTrackingModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodIndex,
    required this.moodLabel,
    required this.notes,
    required this.symptoms,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'moodIndex': moodIndex,
      'moodLabel': moodLabel,
      'notes': notes,
      'symptoms': symptoms.map((e) => e.toMap()).toList(),
    };
  }

  factory SymptomTrackingModel.fromMap(Map<String, dynamic> map) {
    return SymptomTrackingModel(
      id: map['id'],
      userId: map['userId'],
      date: DateTime.parse(map['date']),
      moodIndex: map['moodIndex'],
      moodLabel: map['moodLabel'],
      notes: map['notes'] ?? '',
      symptoms: (map['symptoms'] as List)
          .map((e) => SymptomEntry.fromMap(e))
          .toList(),
    );
  }
}