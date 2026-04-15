import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';

class AppPreferencesRepository {
  static const _onboardingKey = 'fq_has_completed_onboarding';

  Future<AppPreferences> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppPreferences(
        hasCompletedOnboarding: prefs.getBool(_onboardingKey) ?? false,
      );
    } catch (_) {
      return AppPreferences.defaults;
    }
  }

  Future<AppPreferences> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, completed);
    return AppPreferences(hasCompletedOnboarding: completed);
  }
}
