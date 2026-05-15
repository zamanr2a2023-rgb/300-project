/// Stable deck identifiers used across UI, routing, and word assignment.
abstract final class DeckIds {
  static const coreWelshWords = 'core_welsh_words';
  static const starterWords = 'starter_words';
}

class Deck {
  const Deck({
    required this.id,
    required this.name,
    required this.description,
    required this.badgeText,
    required this.emoji,
  });

  final String id;
  final String name;
  final String description;
  final String badgeText;
  final String emoji;
}
