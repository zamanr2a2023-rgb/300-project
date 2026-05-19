import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore_learning_repository.dart';
import '../../data/learning_repository.dart';

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return FirestoreLearningRepository();
});
