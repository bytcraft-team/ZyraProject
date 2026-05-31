import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../data/models/cycle_model.dart';
import '../data/models/user_model.dart';
import '../core/utils/db_helper.dart';
// removed unused imports
import '../core/utils/date_utils.dart';

enum OnboardingSaveState { idle, saving, success, error }

class OnboardingViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Données du Formulaire Onboarding ─────────────────────────
  DateTime? _lastPeriodDate;
  int _cycleDuration = 28;
  int _periodDuration = 5;
  String _regularity = 'Régulier';
  String _mainGoal = 'Suivre mon cycle';

  OnboardingSaveState _state = OnboardingSaveState.idle;
  OnboardingSaveState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Setters pour l'UI ────────────────────────────────────────
  void setLastPeriodDate(DateTime date) {
    _lastPeriodDate = CycleDateUtils.dateOnly(date);
    notifyListeners();
  }

  void setCycleDuration(int duration) {
    _cycleDuration = duration;
    notifyListeners();
  }

  void setPeriodDuration(int duration) {
    _periodDuration = duration;
    notifyListeners();
  }

  void setRegularity(String regularity) {
    _regularity = regularity;
    notifyListeners();
  }

  void setMainGoal(String goal) {
    _mainGoal = goal;
    notifyListeners();
  }

  // ── Soumission globale et Calculs ────────────────────────────
  Future<bool> completeOnboardingAndGenerateFirstCycle() async {
    if (_lastPeriodDate == null) {
      _errorMessage = "Veuillez sélectionner la date de vos dernières règles.";
      _state = OnboardingSaveState.error;
      notifyListeners();
      return false;
    }

    _state = OnboardingSaveState.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await DBHelper.instance.database;
      final user = _auth.currentUser;
      final String cycleId = const Uuid().v4();
      final now = DateTime.now();

      // 1. CALCULS ALGORITHMIQUES DU CYCLE INITIAL
      final int passedDaysSinceStart = now.difference(_lastPeriodDate!).inDays;

      // Si la date saisie est trop ancienne, on ajuste fictivement le départ au cycle actuel
      // pour éviter un jour de cycle aberrant (ex: Jour 54 / 28)
      DateTime adjustedStartDate = _lastPeriodDate!;
      if (passedDaysSinceStart >= _cycleDuration) {
        final int cyclesPassed =
            (passedDaysSinceStart / _cycleDuration).floor();
        adjustedStartDate =
            _lastPeriodDate!.add(Duration(days: cyclesPassed * _cycleDuration));
      }

      // nextPeriodDate is derivable from `firstCycle` (startDate + cycleDuration)

      // 2. INSTANCIATION DES MODÈLES AVEC LES VRAIES DONNÉES
      final userModel = UserModel(
        firstName: user?.displayName ?? 'Hajar',
        lastName: '',
        hasUnreadNotifications: false,
        unreadNotificationCount: 0,
      );

      // Estimate ovulation and fertile window using standard rules (ovulation ≈ cycleLength - 14)
      final DateTime predictedOvulation =
          adjustedStartDate.add(Duration(days: _cycleDuration - 14));
      final DateTime predictedFertilityStart =
          predictedOvulation.subtract(const Duration(days: 5));
      final DateTime predictedFertilityEnd =
          predictedOvulation.add(const Duration(days: 1));

      final firstCycle = CycleModel(
        id: cycleId,
        startDate: adjustedStartDate,
        endDate: null,
        predictedOvulation: predictedOvulation,
        predictedFertilityStart: predictedFertilityStart,
        predictedFertilityEnd: predictedFertilityEnd,
        cycleDuration: _cycleDuration,
        expectedPeriodDuration: _periodDuration,
        regularity: _regularity,
        lastUpdated: now,
        isSynced: 0,
      );

      // 3. TRANSACTION LOCALES (SQLite)
      await db.transaction((txn) async {
        // Sauvegarde du cycle
        await txn.insert(
          'cycles',
          {
            'id': firstCycle.id,
            'start_date': firstCycle.startDate.toIso8601String(),
            'predicted_ovulation':
                firstCycle.predictedOvulation.toIso8601String(),
            'predicted_fertility_start':
                firstCycle.predictedFertilityStart.toIso8601String(),
            'predicted_fertility_end':
                firstCycle.predictedFertilityEnd.toIso8601String(),
            'cycle_duration': firstCycle.cycleDuration,
            'period_duration': firstCycle.expectedPeriodDuration,
            'regularity': firstCycle.regularity,
            'last_updated': firstCycle.lastUpdated.toIso8601String(),
            'is_synced': firstCycle.isSynced,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Génération préventive de la cartographie des logs du mois courant (pour Home et Calendar)
        final int daysInMonth = CycleDateUtils.daysInMonth(now.year, now.month);
        for (int i = 1; i <= daysInMonth; i++) {
          final targetDate = DateTime(now.year, now.month, i);
          final int dayInCycle =
              CycleDateUtils.daysBetween(firstCycle.startDate, targetDate) + 1;

          if (dayInCycle > 0 && dayInCycle <= _cycleDuration) {
            final isPredicted =
                targetDate.isAfter(CycleDateUtils.dateOnly(now));

            await txn.insert(
              'daily_logs',
              {
                'date': CycleDateUtils.storageKey(targetDate),
                'basal_temperature':
                    isPredicted ? null : 36.5 + (dayInCycle * 0.01),
                'flow_intensity':
                    dayInCycle <= _periodDuration ? 'medium' : null,
                'has_data': isPredicted ? 0 : 1,
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      });

      // 4. SYNCHRONISATION CLOUD EN TÂCHE DE FOND NON BLOCANTE (SI SATELLITE INTERNET OK)
      if (user != null) {
        _syncToFirebaseBackground(user.uid, userModel, firstCycle);
      } else {
        debugPrint(
            '🔒 Firebase Auth absent lors de l’onboarding : écriture Firestore différée.');
      }

      _state = OnboardingSaveState.success;
      notifyListeners();
      return true;
    } catch (e, stack) {
      debugPrint("Erreur critique Onboarding : $e\n$stack");
      _errorMessage = "Erreur lors de la configuration du profil.";
      _state = OnboardingSaveState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> _syncToFirebaseBackground(
      String uid, UserModel user, CycleModel cycle) async {
    try {
      final batch = _firestore.batch();
      final currentUser = _auth.currentUser;
      final defaultUsername = currentUser?.displayName ??
          currentUser?.email?.split('@').first ??
          '';

      final userRef = _firestore.collection('users').doc(uid);
      batch.set(
          userRef,
          {
            'first_name': user.firstName,
            'last_name': user.lastName,
            'username': defaultUsername,
            'name': currentUser?.displayName ?? defaultUsername,
            'main_goal': _mainGoal,
            'has_unread_notifications': false,
            'unread_notification_count': 0,
          },
          SetOptions(merge: true));

      final cycleRef = userRef.collection('cycles').doc(cycle.id);
      batch.set(cycleRef, {
        ...cycle.toFirestoreMap(),
        'username': defaultUsername,
        'name': currentUser?.displayName ?? defaultUsername,
      });

      await batch.commit();

      // Flag local mis à jour : Synchronisé !
      final db = await DBHelper.instance.database;
      await db.update('cycles', {'is_synced': 1},
          where: 'id = ?', whereArgs: [cycle.id]);
    } catch (e) {
      debugPrint("Firebase déconnecté. Sauvegarde conservée en local : $e");
    }
  }
}
