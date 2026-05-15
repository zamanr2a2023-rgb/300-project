class Word {
  const Word({
    required this.id,
    required this.welsh,
    required this.english,
    required this.deckId,
    required this.deckName,
    required this.badge,
    required this.order,
    this.pronunciation = '',
    this.emoji = '📖',
    this.image,
  });

  final String id;
  final String welsh;
  final String english;
  final String deckId;
  final String deckName;
  final String badge;
  final int order;
  final String pronunciation;
  final String emoji;
  final String? image;

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      welsh: json['welsh'] as String,
      english: json['english'] as String,
      deckId: json['deckId'] as String,
      deckName: json['deckName'] as String,
      badge: json['badge'] as String,
      order: (json['order'] as num).toInt(),
      pronunciation: json['pronunciation'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📖',
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'welsh': welsh,
        'english': english,
        'deckId': deckId,
        'deckName': deckName,
        'badge': badge,
        'order': order,
        'pronunciation': pronunciation,
        'emoji': emoji,
        'image': image,
      };
}
