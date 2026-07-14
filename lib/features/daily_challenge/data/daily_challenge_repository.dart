import '../models/daily_challenge_models.dart';
import 'daily_challenge_supabase_source.dart';

class DailyChallengeRepository {
  const DailyChallengeRepository(this._source);

  final DailyChallengeSupabaseSource _source;

  Future<DailyChallengeFetchResult> fetchTodayChallenge({
    required String languageCode,
  }) {
    return _source.fetchTodayChallenge(languageCode: languageCode);
  }

  Future<DailyChallengeFetchResult> fetchChallengeByPublishDate({
    required String languageCode,
    required String publishDate,
  }) {
    return _source.fetchChallengeByPublishDate(
      languageCode: languageCode,
      publishDate: publishDate,
    );
  }

  Future<List<DailyChallengeQuestion>> fetchRecentPreviousChallenges({
    required String languageCode,
    int limit = 7,
  }) {
    return _source.fetchRecentPreviousChallenges(
      languageCode: languageCode,
      limit: limit,
    );
  }
}
