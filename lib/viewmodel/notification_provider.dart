import 'package:flutter/material.dart';

import '../models/app_notification_settings.dart';
import '../services/local_notification_service.dart';
import '../services/notification_storage.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationStorage _storage = NotificationStorage();

  AppNotificationSettings _settings =
      const AppNotificationSettings();

  bool _loading = false;
  bool _saved = false;

  AppNotificationSettings get settings => _settings;

  bool get isLoading => _loading;

  bool get isSaved => _saved;

  // ================= LOAD =================

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _settings = await _storage.load();

    _loading = false;
    notifyListeners();
  }

  // ================= RÈGLES =================

  void setRegles(bool value) {
    _settings = _settings.copyWith(regles: value);

    notifyListeners();

    LocalNotificationService.show(
      title: value
          ? "🩸 Notifications règles activées"
          : "🩸 Notifications règles désactivées",
      body: value
          ? "Les rappels des règles sont actifs"
          : "Les rappels des règles sont désactivés",
    );
  }

  // ================= FERTILE =================

  void setFertile(bool value) {
    _settings = _settings.copyWith(fertile: value);

    notifyListeners();

    LocalNotificationService.show(
      title: value
          ? "🌿 Fenêtre fertile activée"
          : "🌿 Fenêtre fertile désactivée",
      body: value
          ? "Les rappels fertilité sont actifs"
          : "Les rappels fertilité sont désactivés",
    );
  }

  // ================= OVULATION =================

  void setOvulation(bool value) {
    _settings = _settings.copyWith(ovulation: value);

    notifyListeners();

    LocalNotificationService.show(
      title: value
          ? "🌸 Ovulation activée"
          : "🌸 Ovulation désactivée",
      body: value
          ? "Les rappels ovulation sont actifs"
          : "Les rappels ovulation sont désactivés",
    );
  }

  // ================= SAVE =================

  Future<void> saveAll() async {
    _loading = true;
    _saved = false;

    notifyListeners();

    await _storage.save(_settings);

    _loading = false;
    _saved = true;

    notifyListeners();

    await LocalNotificationService.show(
      title: "✅ Notifications sauvegardées",
      body: "Tes préférences ont été enregistrées",
    );
  }
}