/// Progress for a vocabulary item (maps to swipe outcomes).
enum WordStatus {
  /// Not yet reviewed.
  unseen('unseen'),
  /// Swiped left — needs more practice.
  dontKnow('dont_know'),
  /// Swiped right — sort of knows it.
  sortOfKnow('sort_of_know'),
  /// Swiped up — knows it.
  known('known');

  const WordStatus(this.storageValue);
  final String storageValue;

  /// Legacy aliases used by older saved progress.
  static const _legacyMap = {
    'new': unseen,
    'learning': sortOfKnow,
    'learned': known,
  };

  static WordStatus fromStorage(Object? raw) {
    final s = raw?.toString();
    final legacy = _legacyMap[s];
    if (legacy != null) return legacy;
    for (final v in WordStatus.values) {
      if (v.storageValue == s) return v;
    }
    return WordStatus.unseen;
  }

  @Deprecated('Use fromStorage')
  static WordStatus fromFirestore(Object? raw) => fromStorage(raw);

  @Deprecated('Use storageValue')
  String get firestoreValue => storageValue;
}
