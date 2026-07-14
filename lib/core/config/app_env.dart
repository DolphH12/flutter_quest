import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class AppEnv {
  static const _defaultChallengeTable = 'daily_questions';

  static bool _loaded = false;
  static bool _supabaseInitialized = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (error) {
      debugPrint('AppEnv: .env not loaded: $error');
    }
    _loaded = true;
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL']?.trim() ?? '';

  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY']?.trim() ?? '';

  static String get dailyChallengeTable =>
      dotenv.env['SUPABASE_DAILY_CHALLENGE_TABLE']?.trim().isNotEmpty == true
      ? dotenv.env['SUPABASE_DAILY_CHALLENGE_TABLE']!.trim()
      : _defaultChallengeTable;

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static bool get isSupabaseInitialized => _supabaseInitialized;

  static Future<void> initializeSupabaseIfConfigured() async {
    if (_supabaseInitialized || !hasSupabaseConfig) return;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabasePublishableKey,
      );
      _supabaseInitialized = true;
    } catch (error) {
      debugPrint('AppEnv: Supabase init failed: $error');
    }
  }
}
