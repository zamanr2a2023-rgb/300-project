import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../../../core/utils/date_week.dart';
import '../../domain/learning_math.dart';
import '../../domain/word_progress.dart';
import '../../domain/word_status.dart';
import '../providers/learning_repository_provider.dart';

class LearningUiState {
  const LearningUiState({
    required this.progress,
    required this.weekActivity,
  });

  final ProgressMap progress;
  final List<int> weekActivity;

  static const LearningUiState empty = LearningUiState(
    progress: {},
    weekActivity: [0, 0, 0, 0, 0, 0, 0],
  );

  int get streak => LearningMath.computeStreak(weekActivity);

  LearningUiState copyWith({
    ProgressMap? progress,
    List<int>? weekActivity,
  }) {
    return LearningUiState(
      progress: progress ?? this.progress,
      weekActivity: weekActivity ?? this.weekActivity,
    );
  }
}

class LearningViewModel extends AsyncNotifier<LearningUiState> {
  @override
  Future<LearningUiState> build() async {
    final sessionAsync = ref.watch(authSessionProvider);
    final uid = sessionAsync.valueOrNull?.id;
    if (uid == null) {
      return LearningUiState.empty;
    }

    final repo = ref.read(learningRepositoryProvider);
    final progress = await repo.fetchProgress(uid);
    final week = await repo.fetchWeekActivity(uid);
    return LearningUiState(progress: progress, weekActivity: week);
  }

  Future<void> refresh() async {
    final uid = ref.read(authSessionProvider).valueOrNull?.id;
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(learningRepositoryProvider);
      final progress = await repo.fetchProgress(uid);
      final week = await repo.fetchWeekActivity(uid);
      return LearningUiState(progress: progress, weekActivity: week);
    });
  }

  /// Optimistic UI matching `AuthedApp.handleReview` in the web app.
  Future<void> recordReview({
    required String wordId,
    required WordStatus status,
  }) async {
    final uid = ref.read(authSessionProvider).valueOrNull?.id;
    final current = state.value;
    if (uid == null || current == null) return;

    final prevCount = current.progress[wordId]?.reviews ?? 0;
    final nextProgress = Map<String, WordProgressEntry>.from(current.progress);
    nextProgress[wordId] = WordProgressEntry(
      status: status,
      reviews: prevCount + 1,
    );

    final todayIdx = DateWeek.todayMondayFirstIndex();
    final nextWeek = List<int>.from(current.weekActivity);
    nextWeek[todayIdx] = (nextWeek[todayIdx]) + 1;

    final optimistic = current.copyWith(
      progress: nextProgress,
      weekActivity: nextWeek,
    );
    state = AsyncData(optimistic);

    try {
      await ref.read(learningRepositoryProvider).recordReview(
            userId: uid,
            wordId: wordId,
            status: status,
          );
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

final learningViewModelProvider =
    AsyncNotifierProvider<LearningViewModel, LearningUiState>(
  LearningViewModel.new,
);
