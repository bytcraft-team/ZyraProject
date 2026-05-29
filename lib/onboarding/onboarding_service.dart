import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_model.dart';

class OnboardingService {
  static const String _profileTypeKey = 'zyra_profile_type';
  static const String _onboardingDataKey = 'zyra_onboarding_data';

  static Future<void> saveUserProfileType(UserProfileType profileType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileTypeKey, profileType.name);
  }

  static Future<UserProfileType?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_profileTypeKey);
    if (stored == null) return null;
    return UserProfileType.values.firstWhere(
      (item) => item.name == stored,
      orElse: () => UserProfileType.cycle,
    );
  }

  static Future<void> saveOnboardingData(OnboardingData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileTypeKey, data.profileType.name);
    await prefs.setString(_onboardingDataKey, jsonEncode(data.toJson()));
  }

  static Future<OnboardingData?> loadOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_onboardingDataKey);
    if (stored == null) return null;
    final json = jsonDecode(stored) as Map<String, dynamic>;
    return OnboardingData.fromJson(json);
  }
}
