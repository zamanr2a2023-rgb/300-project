import '../domain/deck.dart';

/// Canonical deck list for the Home screen and Learn flow.
abstract final class DecksData {
  static const List<Deck> all = [
    Deck(
      id: DeckIds.coreWelshWords,
      name: 'Core Welsh Words',
      description: 'Serious vocabulary from the cleaned Welsh word list',
      badgeText: 'Core Welsh Word',
      emoji: '🐉',
    ),
    Deck(
      id: DeckIds.starterWords,
      name: 'Starter Words',
      description: 'Beginner-friendly Welsh words for new learners',
      badgeText: 'Starter Word',
      emoji: '🍵',
    ),
  ];

  static Deck? byId(String id) {
    for (final deck in all) {
      if (deck.id == id) return deck;
    }
    return null;
  }
}
