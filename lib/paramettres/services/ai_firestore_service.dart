import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  Future<void> saveAiConfig({
    String? uid,
    required Map<String, dynamic> data,
  }) async {
    final userId = uid ?? _uid;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('ai')
        .doc('config')
        .set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getAiConfig() async {
    return await _firestore
        .collection('users')
        .doc(_uid)
        .collection('ai')
        .doc('config')
        .get();
  }
}