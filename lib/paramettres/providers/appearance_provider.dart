import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceProvider extends ChangeNotifier {
  int _selectedColor = 0;
  int _selectedMode = 0;
  int _selectedLang = 0;

  bool _initialized = false;

  bool get initialized => _initialized;

  int get selectedColor => _selectedColor;
  int get selectedMode => _selectedMode;
  int get selectedLang => _selectedLang;

  AppearanceProvider() {
    _init();
  }

  // ================= COLORS =================

  static const List<Color> primaryColors = [
    Color(0xFFE91E8C),
    Color(0xFF9B59B6),
    Color(0xFFB388EB),
    Color(0xFFFF8A65),
    Color(0xFF26A69A),
    Color(0xFF2D1B3D),
  ];

  Color get currentPrimaryColor =>
      primaryColors[_selectedColor.clamp(0, primaryColors.length - 1)];

  // ================= THEME =================

  ThemeMode get themeMode {
    switch (_selectedMode) {
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  ThemeData get lightTheme {
    final seed = currentPrimaryColor;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      scaffoldBackgroundColor: seed.withValues(alpha: 0.12),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: currentPrimaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }

  // ================= LANGUAGE =================

  Locale get locale {
    switch (_selectedLang) {
      case 1:
        return const Locale('en');
      case 2:
        return const Locale('ar');
      default:
        return const Locale('fr');
    }
  }

  // ================= INIT =================

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _selectedColor = prefs.getInt('selectedColor') ?? 0;
    _selectedMode = prefs.getInt('selectedMode') ?? 0;
    _selectedLang = prefs.getInt('selectedLang') ?? 0;

    _initialized = true;
    notifyListeners();
  }

  // ================= UPDATES =================

  Future<void> updateMode(int value) async {
    _selectedMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedMode', value);
    notifyListeners();
  }

  Future<void> updateColor(int value) async {
    _selectedColor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedColor', value);
    notifyListeners();
  }

  Future<void> updateLanguage(int value) async {
    _selectedLang = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedLang', value);
    notifyListeners();
  }
}