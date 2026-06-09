import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../database/pregnancy_dao.dart';
import '../onboarding/onboarding_model.dart';
import 'signup_request.dart';

class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final PregnancyDao _pregnancyDao;

  UserRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      _pregnancyDao = PregnancyDao();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(SignupRequest request) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: request.email,
      password: request.password,
    );

    final user = credential.user;
    await user?.updateDisplayName(request.username);
    await _ensureUserDocument(user, request.username);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> loadCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return {'uid': user.uid, 'email': user.email, ...snapshot.data()!};
    } catch (e) {
      debugPrint('Erreur reading user profile from Firestore: $e');
      return null;
    }
  }

  Future<void> saveOnboardingData(dynamic raw) async {
    final user = currentUser;
    if (user == null) throw StateError('Utilisateur non authentifié');

    Map<String, dynamic> data;
    if (raw is OnboardingData) {
      data = raw.toJson();
    } else if (raw is Map<String, dynamic>) {
      data = raw;
    } else {
      throw ArgumentError('Unsupported onboarding payload');
    }

    final profileType =
        (data['profileType'] ?? data['profile_type'] ?? data['pregnancyStatus'])
            ?.toString() ??
        'cycle';

    final defaultUsername =
        user.displayName ?? user.email?.split('@').first ?? '';
    final userDoc = <String, dynamic>{
      'email': user.email,
      'username': defaultUsername,
      'name': user.displayName ?? defaultUsername,
      'isOnboarded': true,
      'mode':
          profileType == 'pregnancy' ||
              profileType == UserProfileType.pregnancy.name
          ? 'pregnancy'
          : 'cycle',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userDoc, SetOptions(merge: true));

    if (profileType == UserProfileType.pregnancy.name ||
        profileType == 'pregnancy') {
      final lastPeriodDate =
          data['lastMenstrualPeriodDate'] ?? data['last_period_date'];
      final lmpDate = lastPeriodDate is DateTime
          ? lastPeriodDate
          : lastPeriodDate is String
          ? DateTime.tryParse(lastPeriodDate)
          : null;
      final pregnancyWeek =
          data['pregnancyWeek'] ??
          data['pregnancy_week'] ??
          (lmpDate != null ? computePregnancyWeekFromLMP(lmpDate) : null);

      final preg = <String, dynamic>{
        'lastPeriodDate': lastPeriodDate,
        'pregnancyWeek': pregnancyWeek,
        'username': defaultUsername,
        'name': user.displayName ?? defaultUsername,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pregnancy')
          .doc(user.uid)
          .set(preg, SetOptions(merge: true));
    } else {
      final cycle = <String, dynamic>{
        'lastPeriodDate': data['lastPeriodDate'] ?? data['last_period_date'],
        'cycleLength':
            data['averageCycleLength'] ??
            data['cycleLength'] ??
            data['cycle_length'] ??
            28,
        'nextPeriodDate': data['nextPeriodDate'],
        'cycleDay': data['cycleDay'],
        'mood': data['mood'],
        'username': defaultUsername,
        'name': user.displayName ?? defaultUsername,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cycle')
          .doc(user.uid)
          .set(cycle, SetOptions(merge: true));
    }
  }

  Future<void> updatePregnancy(Map<String, dynamic> values) async {
    final user = currentUser;
    if (user == null) throw StateError('Utilisateur non authentifié');
    final defaultUsername =
        user.displayName ?? user.email?.split('@').first ?? '';
    values['username'] = values['username'] ?? defaultUsername;
    values['name'] = values['name'] ?? user.displayName ?? defaultUsername;
    values['updatedAt'] = DateTime.now().toIso8601String();
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('pregnancy')
        .doc(user.uid)
        .set(values, SetOptions(merge: true));
    await _pregnancyDao.savePregnancyTracking(user.uid, values);
    await _firestore.collection('users').doc(user.uid).set({
      'isOnboarded': true,
      'mode': 'pregnancy',
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> updateCycle(Map<String, dynamic> values) async {
    final user = currentUser;
    if (user == null) throw StateError('Utilisateur non authentifié');
    final defaultUsername =
        user.displayName ?? user.email?.split('@').first ?? '';
    values['username'] = values['username'] ?? defaultUsername;
    values['name'] = values['name'] ?? user.displayName ?? defaultUsername;
    values['updatedAt'] = DateTime.now().toIso8601String();
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cycle')
        .doc(user.uid)
        .set(values, SetOptions(merge: true));
    await _firestore.collection('users').doc(user.uid).set({
      'isOnboarded': true,
      'mode': 'cycle',
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> _ensureUserDocument(User? user, String username) async {
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'username': username,
      'name': user.displayName ?? username,
      'createdAt': DateTime.now().toIso8601String(),
      'isOnboarded': false,
      'mode': null,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  int computePregnancyWeekFromLMP(DateTime lmp) {
    final now = DateTime.now();
    final days = now.difference(lmp).inDays;
    return (days / 7).floor() + 1;
  }

  DateTime computeExpectedDueDate(DateTime lmp) {
    return lmp.add(const Duration(days: 280));
  }

  DateTime computeNextPeriodDate(DateTime lastPeriodStart, int cycleLength) {
    return lastPeriodStart.add(Duration(days: cycleLength));
  }

  int computeCycleDay(DateTime lastPeriodStart) {
    final today = DateTime.now();
    final diff = today.difference(lastPeriodStart).inDays;
    return diff + 1;
  }

  Future<void> savePregnancySymptoms({
    required String dateKey,
    required int weekNumber,
    required int moodIndex,
    required String notes,
    required List<Map<String, dynamic>> symptoms,
    required DateTime expectedDeliveryDate,
  }) async {
    debugPrint('🔐 [REPO] Vérification authentification...');
    final user = currentUser;
    debugPrint(
      '👤 [REPO] currentUser: ${user?.uid ?? 'NULL - PAS AUTHENTIFIÉ'}',
    );
    debugPrint('📧 [REPO] Email: ${user?.email ?? 'N/A'}');

    if (user == null) {
      debugPrint('❌ [REPO] ERREUR: Utilisateur non authentifié!');
      throw StateError('Utilisateur non authentifié');
    }

    final payload = <String, dynamic>{
      'uid': user.uid,
      'dateKey': dateKey,
      'weekNumber': weekNumber,
      'moodIndex': moodIndex,
      'notes': notes.trim(),
      'symptoms': symptoms,
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    debugPrint('[REPO] === Payload à sauvegarder ===');
    debugPrint('[REPO] dateKey: $dateKey');
    debugPrint('[REPO] weekNumber: $weekNumber');
    debugPrint('[REPO] moodIndex: $moodIndex');
    debugPrint(
      '[REPO] notes: ${notes.trim().isEmpty ? "(vides)" : notes.substring(0, (20 < notes.length ? 20 : notes.length))}',
    );
    debugPrint('[REPO] symptoms.length: ${symptoms.length}');
    for (int i = 0; i < symptoms.length; i++) {
      final s = symptoms[i];
      debugPrint('[REPO]   [$i] ${s['label']}: ${s['intensity']}');
    }
    debugPrint('[REPO] === Fin Payload ===');

    try {
      debugPrint('🚀 [REPO] Écriture Firestore en cours...');
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pregnancySymptoms')
          .doc(dateKey)
          .set(payload, SetOptions(merge: true));
      debugPrint('✅ [REPO] Écriture pregnancySymptoms réussie!');
    } catch (e) {
      debugPrint('❌ [REPO] ERREUR écriture pregnancySymptoms: $e');
      rethrow;
    }

    try {
      debugPrint('🚀 [REPO] Mise à jour lastPregnancySymptomEntry...');
      await _firestore.collection('users').doc(user.uid).set({
        'lastPregnancySymptomEntry': payload,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      debugPrint('✅ [REPO] Mise à jour lastPregnancySymptomEntry réussie!');
    } catch (e) {
      debugPrint('❌ [REPO] ERREUR mise à jour lastPregnancySymptomEntry: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadPregnancySymptomsForDate(
    String dateKey,
  ) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pregnancySymptoms')
          .doc(dateKey)
          .get();

      return snapshot.exists ? snapshot.data() : null;
    } catch (e) {
      debugPrint('Erreur lors du chargement des symptômes: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> loadPregnancySymptomsHistory({
    int limit = 7,
  }) async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pregnancySymptoms')
          .orderBy('dateKey', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {'docId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint(
        'Erreur lors du chargement de l\'historique des symptômes: $e',
      );
      return [];
    }
  }

  /// Sauvegarde les données de suivi de grossesse
  Future<void> savePregnancyTracking(Map<String, dynamic> trackingData) async {
    final user = currentUser;
    if (user == null) throw StateError('Utilisateur non authentifié');

    try {
      // Sauvegarde dans le document utilisateur principal
      await _firestore.collection('users').doc(user.uid).set({
        'pregnancyTracking': trackingData,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Aussi sauvegarde dans la sous-collection pregnancy pour accès rapide
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pregnancy')
          .doc(user.uid)
          .set(trackingData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde Firestore grossesse: $e');
    }

    await _pregnancyDao.savePregnancyTracking(user.uid, trackingData);
  }

  /// Charge les données de suivi de grossesse
  Future<Map<String, dynamic>?> loadPregnancyTracking() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pregnancy')
          .doc(user.uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data();
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors du chargement des données de suivi: $e');
      return null;
    }
  }
}
