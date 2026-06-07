import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

abstract class SettingsRepository {
  Future<CycleSettings> getSettings();
  Future<void> saveSettings(CycleSettings settings);
  Future<bool> completeOnboarding(CycleSettings settings);
  Future<void> deleteHistoryEntry(String id);
  Future<void> updateHistoryEntry(CycleHistoryEntry entry);
}

class SettingsRepositoryImpl implements SettingsRepository {
  static const _prefsKeyBase = 'cycle_settings_v1';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CycleSettings _settings = const CycleSettings(
    onboardingCompleted: false,
    hasCompletedCycleQuestions: false,
    history: [],
  );

  String _prefsKeyForUser(String? uid) {
    if (uid == null || uid.isEmpty) {
      return _prefsKeyBase;
    }
    return '${_prefsKeyBase}_$uid';
  }

  SettingsRepositoryImpl();

  @override
  Future<CycleSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _auth.currentUser?.uid;
    final key = _prefsKeyForUser(userId);
    final raw = prefs.getString(key);

    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _settings = CycleSettings.fromMap(map);
        debugPrint(
          'getSettings: local flag for key=$key loaded => hasCompletedCycleQuestions=${_settings.hasCompletedCycleQuestions}',
        );
      } catch (_) {
        // En cas de données corrompues, retour au modèle par défaut
      }
    }

    if (_auth.currentUser != null) {
      try {
        final snapshot = await _firestore.collection('users').doc(userId).get();
        if (snapshot.exists && snapshot.data() != null) {
          final firestoreSettings = _cycleSettingsFromFirestore(
            snapshot.data()!,
          );
          debugPrint(
            'getSettings: Firestore flag for user=$userId => hasCompletedCycleQuestions=${firestoreSettings.hasCompletedCycleQuestions}',
          );
          if (!_settings.hasCompletedCycleQuestions &&
              firestoreSettings.hasCompletedCycleQuestions) {
            _settings = firestoreSettings;
            await prefs.setString(key, jsonEncode(_settings.toMap()));
          } else if (raw == null) {
            _settings = firestoreSettings;
            await prefs.setString(key, jsonEncode(_settings.toMap()));
          }
        }
      } catch (e) {
        debugPrint(
          'Erreur lors de la récupération du settings depuis Firestore: $e',
        );
      }
    }

    return _settings;
  }

  CycleSettings _cycleSettingsFromFirestore(
    Map<String, dynamic> firestoreData,
  ) {
    return CycleSettings(
      onboardingCompleted:
          firestoreData['onboardingCompleted'] as bool? ?? false,
      hasCompletedCycleQuestions:
          firestoreData['hasCompletedCycleQuestions'] as bool? ??
          firestoreData['cycleSetupCompleted'] as bool? ??
          firestoreData['onboardingCompleted'] as bool? ??
          false,
      lastPeriodStart: _parseDate(firestoreData['lastPeriodStart']),
      cycleDuration: firestoreData['cycleDuration'] is int
          ? firestoreData['cycleDuration'] as int
          : int.tryParse(firestoreData['cycleDuration']?.toString() ?? '') ??
                28,
      periodDuration: firestoreData['periodDuration'] is int
          ? firestoreData['periodDuration'] as int
          : int.tryParse(firestoreData['periodDuration']?.toString() ?? '') ??
                5,
      regularity: _parseRegularity(firestoreData['regularity']),
      goal: _parseGoal(firestoreData['goal']),
      notifications: firestoreData['notifications'] is Map
          ? NotificationSettings.fromMap(
              Map<String, dynamic>.from(firestoreData['notifications'] as Map),
            )
          : const NotificationSettings(),
      history: const [],
      userName: firestoreData['userName'] as String? ?? '',
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  CycleRegularity _parseRegularity(dynamic raw) {
    if (raw is int && raw >= 0 && raw < CycleRegularity.values.length) {
      return CycleRegularity.values[raw];
    }
    if (raw is String) {
      try {
        return CycleRegularity.values.firstWhere(
          (item) =>
              item.name == raw || item.label.toLowerCase() == raw.toLowerCase(),
        );
      } catch (_) {
        // ignore
      }
    }
    return CycleRegularity.regular;
  }

  UserGoal _parseGoal(dynamic raw) {
    if (raw is int && raw >= 0 && raw < UserGoal.values.length) {
      return UserGoal.values[raw];
    }
    if (raw is String) {
      try {
        return UserGoal.values.firstWhere(
          (item) =>
              item.name == raw || item.label.toLowerCase() == raw.toLowerCase(),
        );
      } catch (_) {
        // ignore
      }
    }
    return UserGoal.simpleTracking;
  }

  @override
  Future<void> saveSettings(CycleSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser(_auth.currentUser?.uid);
    _settings = settings;
    await prefs.setString(key, jsonEncode(_settings.toMap()));
  }

  @override
  Future<bool> completeOnboarding(CycleSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser(_auth.currentUser?.uid);
    _settings = settings.copyWith(
      onboardingCompleted: true,
      hasCompletedCycleQuestions: true,
    );
    await prefs.setString(key, jsonEncode(_settings.toMap()));
    debugPrint(
      'completeOnboarding: local flag saved for key=$key; hasCompletedCycleQuestions=${_settings.hasCompletedCycleQuestions}',
    );

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint(
        'completeOnboarding: pas d\'utilisateur Firebase connecté, impossible de synchroniser Firestore.',
      );
      return false;
    }

    final success = await _syncOnboardingToFirebase(_settings);
    if (!success) {
      debugPrint(
        'completeOnboarding: la synchronisation Firestore a échoué pour user=${user.uid}.',
      );
      return false;
    }

    debugPrint(
      'completeOnboarding: onboarding sauvegardé en local et en Firestore pour user=${user.uid}.',
    );
    return true;
  }

  Future<bool> _syncOnboardingToFirebase(CycleSettings settings) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'isOnboarded': true,
        'mode': 'cycle',
        'cycleSetupCompleted': true,
        'onboardingCompleted': true,
        'hasCompletedCycleQuestions': true,
        'lastPeriodStart': settings.lastPeriodStart?.toIso8601String(),
        'cycleDuration': settings.cycleDuration,
        'periodDuration': settings.periodDuration,
        'regularity': settings.regularity.name,
        'goal': settings.goal.name,
        'lastUpdated': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      debugPrint(
        'Onboarding synchronisé vers Firestore pour user ${user.uid}.',
      );
    } catch (e) {
      debugPrint('Erreur Firestore onboarding sync: $e');
      return false;
    }
    return true;
  }

  @override
  Future<void> deleteHistoryEntry(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updated = _settings.history.where((e) => e.id != id).toList();
    _settings = _settings.copyWith(history: updated);

    // Ajouté : Sauvegarde immédiate dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser(_auth.currentUser?.uid);
    await prefs.setString(key, jsonEncode(_settings.toMap()));
  }

  @override
  Future<void> updateHistoryEntry(CycleHistoryEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updated = _settings.history
        .map((e) => e.id == entry.id ? entry : e)
        .toList();
    _settings = _settings.copyWith(history: updated);

    // Ajouté : Sauvegarde immédiate dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser(_auth.currentUser?.uid);
    await prefs.setString(key, jsonEncode(_settings.toMap()));
  }
}
