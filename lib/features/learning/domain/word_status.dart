/// Matches Postgres enum `word_status` / TS `WordStatus`.
enum WordStatus {
  newWord('new'),
  learning('learning'),
  learned('learned');

  const WordStatus(this.firestoreValue);
  final String firestoreValue;

  static WordStatus fromFirestore(Object? raw) {
    final s = raw?.toString();
    for (final v in WordStatus.values) {
      if (v.firestoreValue == s) return v;
    }
    return WordStatus.newWord;
  }
}
