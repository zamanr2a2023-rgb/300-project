import 'word_progress.dart';
import 'word_status.dart';

/// Same algorithms as `src/lib/learning.ts`.
abstract final class LearningMath {
  static int computeStreak(List<int> activity) {
    var streak = 0;
    for (var i = activity.length - 1; i >= 0; i--) {
      if (activity[i] > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static ({
    int learned,
    int learning,
    int total,
    int pct,
  }) summarizeProgress(
    ProgressMap progress, {
    required int vocabularyTotal,
  }) {
    final vals = progress.values;
    final learned = vals.where((p) => p.status == WordStatus.known).length;
    final learning = vals
        .where((p) =>
            p.status == WordStatus.sortOfKnow ||
            p.status == WordStatus.dontKnow)
        .length;
    final total = vocabularyTotal;
    final pct = total == 0 ? 0 : ((learned / total) * 100).round();
    return (learned: learned, learning: learning, total: total, pct: pct);
  }
}
