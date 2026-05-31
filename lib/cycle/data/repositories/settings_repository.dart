import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

abstract class SettingsRepository {
  Future<CycleSettings> getSettings();
  Future<void> saveSettings(CycleSettings settings);
  Future<void> completeOnboarding(CycleSettings settings);
  Future<void> deleteHistoryEntry(String id);
  Future<void> updateHistoryEntry(CycleHistoryEntry entry);
}

class SettingsRepositoryImpl implements SettingsRepository {
  static const _prefsKey = 'cycle_settings_v1';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CycleSettings _settings = CycleSettings(
    onboardingCompleted: false,
    history: [
      CycleHistoryEntry(
        id: '1',
        startDate: DateTime.now().subtract(const Duration(days: 56)),
        endDate: DateTime.now().subtract(const Duration(days: 29)),
        duration: 27,
        periodDuration: 5,
        regularity: 'Régulier',
      ),
      CycleHistoryEntry(
        id: '2',
        startDate: DateTime.now().subtract(const Duration(days: 28)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        duration: 27,
        periodDuration: 4,
        regularity: 'Régulier',
      ),
      CycleHistoryEntry(
        id: '3',
        startDate: DateTime.now().subtract(const Duration(days: 84)),
        endDate: DateTime.now().subtract(const Duration(days: 57)),
        duration: 27,
        periodDuration: 6,
        regularity: 'Légèrement irrégulier',
      ),
    ],
  );

  SettingsRepositoryImpl();

  @override
  Future<CycleSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _settings = CycleSettings.fromMap(map);
      } catch (_) {
        // En cas de données corrompues, retour au modèle par défaut
      }
    }
    return _settings;
  }

  @override
  Future<void> saveSettings(CycleSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    _settings = settings;
    await prefs.setString(_prefsKey, jsonEncode(_settings.toMap()));
  }

  @override
  Future<void> completeOnboarding(CycleSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    _settings = settings.copyWith(onboardingCompleted: true);
    await prefs.setString(_prefsKey, jsonEncode(_settings.toMap()));

    // Envoi asynchrone vers Firestore si l'utilisateur est connecté
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Onboarding local saved, mais aucun utilisateur Firebase connecté.');
      return;
    }

    _syncOnboardingToFirebase(_settings).catchError((e) {
      debugPrint('Échec de la synchronisation Firestore de l\'onboarding : $e');
    });
  }

  Future<void> _syncOnboardingToFirebase(CycleSettings settings) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'onboardingCompleted': true,
          'lastPeriodStart': settings.lastPeriodStart?.toIso8601String(),
          'cycleDuration': settings.cycleDuration,
          'periodDuration': settings.periodDuration,
          'regularity': settings.regularity.name,
          'goal': settings.goal.name,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      debugPrint('Onboarding synchronisé vers Firestore pour user ${user.uid}.');
    } catch (e) {
      debugPrint('Erreur Firestore onboarding sync: $e');
    }
  }

  @override
  Future<void> deleteHistoryEntry(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updated = _settings.history
        .where((e) => e.id != id)
        .toList();
    _settings = _settings.copyWith(history: updated);
    
    // Ajouté : Sauvegarde immédiate dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_settings.toMap()));
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
    await prefs.setString(_prefsKey, jsonEncode(_settings.toMap()));
  }
}