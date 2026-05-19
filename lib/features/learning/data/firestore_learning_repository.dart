import '../domain/word_progress.dart';
import '../domain/word_status.dart';
import 'learning_repository.dart';
import 'progress_service.dart';

class FirestoreLearningRepository implements LearningRepository {
  FirestoreLearningRepository({ProgressService? progressService})
      : _progress = progressService ?? ProgressService();

  final ProgressService _progress;

  @override
  Future<ProgressMap> fetchProgress(String userId) =>
      _progress.fetchProgress(userId);

  @override
  Future<List<int>> fetchWeekActivity(String userId) =>
      _progress.fetchWeekActivity(userId);

  @override
  Future<void> recordReview({
    required String userId,
    required String wordId,
    required String deckId,
    required WordStatus status,
    required int reviewCount,
  }) {
    return _progress.recordReview(
      userId: userId,
      wordId: wordId,
      deckId: deckId,
      status: status,
      reviewCount: reviewCount,
    );
  }
}
