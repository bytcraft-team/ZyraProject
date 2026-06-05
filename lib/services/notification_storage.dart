import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification_settings.dart';

class NotificationStorage {
  static const _keyRegles = 'notification_r-egles';
  static const _keyFertile = 'notification_fertile';
  static const _keyOvulation = 'notification_ovulation';

  Future<AppNotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return AppNotificationSettings(
      regles: prefs.getBool(_keyRegles) ?? true,
      fertile: prefs.getBool(_keyFertile) ?? true,
      ovulation: prefs.getBool(_keyOvulation) ?? true,
    );
  }

  Future<void> save(AppNotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyRegles, settings.regles);
    await prefs.setBool(_keyFertile, settings.fertile);
    await prefs.setBool(_keyOvulation, settings.ovulation);
  }
}