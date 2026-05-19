import '../domain/word_progress.dart';
import '../domain/word_status.dart';

/// Persists swipe progress per authenticated user.
abstract class LearningRepository {
  Future<ProgressMap> fetchProgress(String userId);

  Future<List<int>> fetchWeekActivity(String userId);

  Future<void> recordReview({
    required String userId,
    required String wordId,
    required String deckId,
    required WordStatus status,
    required int reviewCount,
  });
}
