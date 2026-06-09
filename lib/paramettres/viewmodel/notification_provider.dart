import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/app_notification_settings.dart';
import '../services/local_notification_service.dart';
import '../services/notification_storage.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationStorage _storage = NotificationStorage();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  AppNotificationSettings _settings = const AppNotificationSettings();
  bool _loading = false;
  bool _saved = false;

  AppNotificationSettings get settings => _settings;
  bool get isLoading => _loading;
  bool get isSaved => _saved;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _settings = await _storage.load();
    _loading = false;
    notifyListeners();
  }

  // Méthode interne pour gérer les abonnements aux topics Firebase 📡
  Future<void> _toggleFirebaseTopic(String topic, bool enable) async {
    try {
      if (enable) {
        await _fcm.subscribeToTopic(topic);
        print("✅ [Firebase] Abonnement au topic réussi: $topic");
      } else {
        await _fcm.unsubscribeFromTopic(topic);
        print("❌ [Firebase] Désabonnement du topic réussi: $topic");
      }
    } catch (e) {
      print("⚠️ Erreur lors de la mise à jour du topic Firebase: $e");
    }
  }

  void setRegles(bool value) {
    _settings = _settings.copyWith(regles: value);
    notifyListeners();
    _toggleFirebaseTopic('regles', value);
    LocalNotificationService.show(
      title: value ? "🩸 Notifications règles activées" : "🩸 Notifications règles désactivées",
      body: value ? "Synchronisé avec Firebase" : "Rappels Cloud désactivés",
    );
  }

  void setFertile(bool value) {
    _settings = _settings.copyWith(fertile: value);
    notifyListeners();
    _toggleFirebaseTopic('fertile', value);
    LocalNotificationService.show(
      title: value ? "🌿 Fenêtre fertile activée" : "🌿 Fenêtre fertile désactivée",
      body: value ? "Suivi fertile actif" : "Suivi désactivé",
    );
  }

  void setOvulation(bool value) {
    _settings = _settings.copyWith(ovulation: value);
    notifyListeners();
    _toggleFirebaseTopic('ovulation', value);
    LocalNotificationService.show(
      title: value ? "🌸 Ovulation activée" : "🌸 Ovulation désactivée",
      body: value ? "Rappels ovulation activés" : "Rappels désactivés",
    );
  }

  void setGrossesse(bool value) {
    _settings = _settings.copyWith(grossesse: value);
    notifyListeners();
    _toggleFirebaseTopic('grossesse', value);
    LocalNotificationService.show(
      title: value ? "🤰 Notifications grossesse activées" : "🤰 Notifications grossesse désactivées",
      body: value ? "Suivi grossesse actif" : "Rappels désactivés",
    );
  }

  Future<void> saveAll() async {
    _loading = true;
    _saved = false;
    notifyListeners();

    print("💾 Sauvegarde des paramètres...");
    await _storage.save(_settings);

    print("📡 Mise à jour des topics Firebase...");
    await _toggleFirebaseTopic('regles', _settings.regles);
    await _toggleFirebaseTopic('fertile', _settings.fertile);
    await _toggleFirebaseTopic('ovulation', _settings.ovulation);
    await _toggleFirebaseTopic('grossesse', _settings.grossesse);

    _loading = false;
    _saved = true;
    notifyListeners();

    await LocalNotificationService.show(
      title: "✅ Choix enregistrés",
      body: "Vos préférences sont à jour !",
    );
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // 1. Rappel règles
  Future<void> scheduleReglesReminder(DateTime prochaineDateRegles) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notificationsPlugin.zonedSchedule(
        101, 
        'Rappel : cycle à venir 🌸', 
        'Vos prochaines règles sont prévues pour bientôt.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'regles_channel', 'Cycle Menstruel', importance: Importance.max, priority: Priority.high
          )
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // 2. Rappel ovulation
  Future<void> scheduleOvulationReminder(DateTime dateOvulation) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 90));
    
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notificationsPlugin.zonedSchedule(
        303, 
        'Période fertile 🌸✨', 
        'C\'est le moment idéal pour la fertilité.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ovulation_channel', 'Ovulation', importance: Importance.max, priority: Priority.high
          )
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // 3. Rappel grossesse
  Future<void> scheduleAccouchementReminder(DateTime dateAccouchementPrevue) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 2));
    
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notificationsPlugin.zonedSchedule(
        202, 
        'Suivi de grossesse ✨👶', 
        'N\'oubliez pas votre suivi hebdomadaire.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'grossesse_channel', 'Grossesse', importance: Importance.max, priority: Priority.high
          )
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}