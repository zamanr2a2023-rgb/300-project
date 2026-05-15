import '../../../core/utils/date_week.dart';
import '../domain/word_progress.dart';
import '../domain/word_status.dart';

/// In-memory progress for design / offline demo (no backend).
final _demoProgress = <String, WordProgressEntry>{};
final _demoWeekActivity = List<int>.filled(7, 0);

class LearningRepository {
  LearningRepository();

  Future<ProgressMap> fetchProgress(String userId) async {
    return Map<String, WordProgressEntry>.from(_demoProgress);
  }

  Future<void> recordReview({
    required String userId,
    required String wordId,
    required WordStatus status,
  }) async {
    final prev = _demoProgress[wordId]?.reviews ?? 0;
    _demoProgress[wordId] = WordProgressEntry(status: status, reviews: prev + 1);
    final todayIdx = DateWeek.todayMondayFirstIndex();
    _demoWeekActivity[todayIdx] = _demoWeekActivity[todayIdx] + 1;
  }

  Future<List<int>> fetchWeekActivity(String userId) async {
    return List<int>.from(_demoWeekActivity);
  }
}
