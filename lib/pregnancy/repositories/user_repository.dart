import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../onboarding/onboarding_model.dart';
import 'signup_request.dart';

class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

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
      'mode': profileType == 'pregnancy' ||
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
      final preg = <String, dynamic>{
        'lastPeriodDate':
            data['lastMenstrualPeriodDate'] ?? data['last_period_date'] ?? null,
        'pregnancyWeek':
            data['pregnancyWeek'] ?? data['pregnancy_week'] ?? null,
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
        'lastPeriodDate':
            data['lastPeriodDate'] ?? data['last_period_date'] ?? null,
        'cycleLength': data['averageCycleLength'] ??
            data['cycleLength'] ??
            data['cycle_length'] ??
            28,
        'nextPeriodDate': data['nextPeriodDate'] ?? null,
        'cycleDay': data['cycleDay'] ?? null,
        'mood': data['mood'] ?? null,
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

  /// Sauvegarde les données de suivi de grossesse
  Future<void> savePregnancyTracking(Map<String, dynamic> trackingData) async {
    final user = currentUser;
    if (user == null) throw StateError('Utilisateur non authentifié');

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
