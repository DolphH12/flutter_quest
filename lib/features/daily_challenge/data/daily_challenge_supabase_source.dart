import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_env.dart';
import '../models/daily_challenge_models.dart';

class DailyChallengeSupabaseSource {
  const DailyChallengeSupabaseSource();

  static const _requestTimeout = Duration(seconds: 8);

  Future<DailyChallengeFetchResult> fetchTodayChallenge({
    required String languageCode,
  }) async {
    final client = _buildClient();
    if (client == null) {
      return const DailyChallengeFetchResult.unavailable(
        debugMessage: 'Supabase is not configured.',
      );
    }

    final today = dailyChallengeLocalDayKey();

    try {
      final response = await client
          .from(AppEnv.dailyChallengeTable)
          .select()
          .eq('is_active', true)
          .lte('publish_date', today)
          .order('publish_date', ascending: false)
          .limit(1)
          .timeout(_requestTimeout);

      if (response.isEmpty) {
        return const DailyChallengeFetchResult.empty();
      }

      final raw = Map<String, dynamic>.from(response.first as Map);

      return DailyChallengeFetchResult.ready(
        _parseQuestion(raw, languageCode: languageCode),
      );
    } on TimeoutException catch (error) {
      return DailyChallengeFetchResult.error(debugMessage: error.toString());
    } catch (error) {
      if (_looksOffline(error)) {
        return DailyChallengeFetchResult.offline(
          debugMessage: error.toString(),
        );
      }
      return DailyChallengeFetchResult.error(debugMessage: error.toString());
    }
  }

  Future<DailyChallengeFetchResult> fetchChallengeByPublishDate({
    required String languageCode,
    required String publishDate,
  }) async {
    final client = _buildClient();
    if (client == null) {
      return const DailyChallengeFetchResult.unavailable(
        debugMessage: 'Supabase is not configured.',
      );
    }

    try {
      final response = await client
          .from(AppEnv.dailyChallengeTable)
          .select()
          .eq('is_active', true)
          .eq('publish_date', publishDate)
          .limit(1)
          .timeout(_requestTimeout);

      if (response.isEmpty) {
        return const DailyChallengeFetchResult.empty();
      }

      final raw = Map<String, dynamic>.from(response.first as Map);
      return DailyChallengeFetchResult.ready(
        _parseQuestion(raw, languageCode: languageCode),
      );
    } on TimeoutException catch (error) {
      return DailyChallengeFetchResult.error(debugMessage: error.toString());
    } catch (error) {
      if (_looksOffline(error)) {
        return DailyChallengeFetchResult.offline(
          debugMessage: error.toString(),
        );
      }
      return DailyChallengeFetchResult.error(debugMessage: error.toString());
    }
  }

  Future<List<DailyChallengeQuestion>> fetchRecentPreviousChallenges({
    required String languageCode,
    int limit = 7,
  }) async {
    final client = _buildClient();
    if (client == null) {
      throw const FormatException('Supabase is not configured.');
    }

    final today = dailyChallengeLocalDayKey();
    final response = await client
        .from(AppEnv.dailyChallengeTable)
        .select()
        .eq('is_active', true)
        .lt('publish_date', today)
        .order('publish_date', ascending: false)
        .limit(limit)
        .timeout(_requestTimeout);

    return response
        .map(
          (row) => _parseQuestion(
            Map<String, dynamic>.from(row as Map),
            languageCode: languageCode,
          ),
        )
        .toList(growable: false);
  }

  SupabaseClient? _buildClient() {
    if (!AppEnv.hasSupabaseConfig || !AppEnv.isSupabaseInitialized) {
      return null;
    }
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  DailyChallengeQuestion _parseQuestion(
    Map<String, dynamic> json, {
    required String languageCode,
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    final question = _pickLocalizedString(
      json['question'],
      languageCode: normalizedLanguage,
    );
    final topic = _pickLocalizedString(
      json['topic'],
      languageCode: normalizedLanguage,
    );
    final explanation = _pickLocalizedString(
      json['explanation'],
      languageCode: normalizedLanguage,
    );
    final options = _pickLocalizedList(
      json['options'],
      languageCode: normalizedLanguage,
    );
    final correctIndex = (json['correct_index'] as num?)?.toInt() ?? -1;
    if (topic.isEmpty || question.isEmpty || explanation.isEmpty) {
      throw const FormatException(
        'Daily challenge is missing localized text fields.',
      );
    }
    if (options.length != 4 || options.any((option) => option.isEmpty)) {
      throw const FormatException(
        'Daily challenge must provide exactly 4 options.',
      );
    }
    if (correctIndex < 0 || correctIndex >= options.length) {
      throw const FormatException('Daily challenge has an invalid correct_index.');
    }

    return DailyChallengeQuestion(
      id: '${json['id'] ?? ''}'.trim(),
      publishDate: DateTime.parse('${json['publish_date'] ?? ''}'),
      level: (json['level'] as num?)?.toInt() ?? 1,
      difficulty: _difficultyFromString('${json['difficulty'] ?? ''}'),
      topic: topic,
      question: question,
      codeSnippet: _nullableString(json['code_snippet']),
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
    );
  }

  String _pickLocalizedString(dynamic raw, {required String languageCode}) {
    if (raw is Map) {
      final localized = raw[languageCode] ?? raw['es'] ?? raw['en'];
      return (localized ?? '').toString().trim();
    }
    return (raw ?? '').toString().trim();
  }

  List<String> _pickLocalizedList(dynamic raw, {required String languageCode}) {
    dynamic resolved = raw;
    if (raw is Map) {
      resolved = raw[languageCode] ?? raw['es'] ?? raw['en'];
    }
    if (resolved is! List) return const <String>[];
    return resolved.map((item) => item.toString().trim()).toList(growable: false);
  }

  String? _nullableString(dynamic raw) {
    final value = (raw ?? '').toString().trim();
    return value.isEmpty ? null : value;
  }

  DailyChallengeDifficulty _difficultyFromString(String raw) {
    return switch (raw.toLowerCase().trim()) {
      'easy' => DailyChallengeDifficulty.easy,
      'medium' => DailyChallengeDifficulty.medium,
      'hard' => DailyChallengeDifficulty.hard,
      _ => DailyChallengeDifficulty.unknown,
    };
  }

  bool _looksOffline(Object error) {
    final raw = error.toString().toLowerCase();
    return raw.contains('socketexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('timed out') ||
        raw.contains('network') ||
        raw.contains('clientexception');
  }
}
