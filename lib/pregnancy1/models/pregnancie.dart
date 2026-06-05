class Pregnancies {
  final String? localId;
  final String? uid;
  final String userId;
  final DateTime startDate;
  final DateTime dueDate;
  //currentWeek ..
  String notes;

  Pregnancies({
    this.localId,
    this.uid,
    required this.userId,
    required this.startDate,
    required this.dueDate,
    required this.notes,
  });
}
