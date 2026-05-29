class Symptoms {
  final String? localId;
  final String? uid;
  final String userId;
  final DateTime date;
  final String symptom;
  //intensity :

  Symptoms({
    this.localId,
    this.uid,
    required this.userId,
    required this.date,
    required this.symptom,
  });
}
