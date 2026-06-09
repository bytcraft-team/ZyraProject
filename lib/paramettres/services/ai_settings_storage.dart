import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyra/paramettres/models/aiconfig.dart';

class AiSettingsStorage {
  static const _keyAiActif = 'ai_actif';
  static const _keyCycle = 'cycle';
  static const _keyGrossesse = 'grossesse';
  static const _keySymptomes = 'symptomes';
  static const _keySuggestions = 'suggestions';
  static const _keyNiveau = 'niveau';

  static Future<void> save(AiConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyAiActif, config.aiActif);
    await prefs.setBool(_keyCycle, config.cycle);
    await prefs.setBool(_keyGrossesse, config.grossesse);
    await prefs.setBool(_keySymptomes, config.symptomes);
    await prefs.setBool(_keySuggestions, config.suggestions);
    await prefs.setInt(_keyNiveau, config.niveau);
  }

  static Future<AiConfig> load() async {
    final prefs = await SharedPreferences.getInstance();

    return AiConfig(
      aiActif: prefs.getBool(_keyAiActif) ?? true,
      cycle: prefs.getBool(_keyCycle) ?? true,
      grossesse: prefs.getBool(_keyGrossesse) ?? true,
      symptomes: prefs.getBool(_keySymptomes) ?? true,
      suggestions: prefs.getBool(_keySuggestions) ?? true,
      niveau: prefs.getInt(_keyNiveau) ?? 1,
    );
  }
}