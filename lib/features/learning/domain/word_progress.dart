import '../domain/word_status.dart';

class WordProgressEntry {
  const WordProgressEntry({
    required this.status,
    required this.reviews,
  });

  final WordStatus status;
  final int reviews;
}

typedef ProgressMap = Map<String, WordProgressEntry>;
