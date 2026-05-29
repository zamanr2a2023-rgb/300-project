import '../domain/deck.dart';

/// Canonical deck list for the Home screen and Learn flow.
abstract final class DecksData {
  static const List<Deck> all = [
    Deck(
      id: DeckIds.starterWords,
      name: 'Starter Words',
      description: 'Beginner-friendly Welsh words for new learners',
      badgeText: 'Starter Word',
      emoji: '🍵',
    ),
    Deck(
      id: DeckIds.coreWelshWords,
      name: 'Core Welsh Words',
      description: 'Serious vocabulary from the cleaned Welsh word list',
      badgeText: 'Core Welsh Word',
      emoji: '🐉',
    ),
    Deck(
      id: DeckIds.daysAndMonths,
      name: 'Days and Months',
      description: 'Days of the week and months of the year',
      badgeText: 'Days & Months',
      emoji: '📅',
    ),
    Deck(
      id: DeckIds.phrases,
      name: 'Phrases',
      description: 'Everyday Welsh greetings and useful phrases',
      badgeText: 'Phrase',
      emoji: '💬',
    ),
    Deck(
      id: DeckIds.talkingAboutMe,
      name: 'Talking about me',
      description: 'Pronouns and words for talking about yourself',
      badgeText: 'About me',
      emoji: '🙋',
    ),
    Deck(
      id: DeckIds.animals,
      name: 'Animals',
      description: 'Common animal names in Welsh',
      badgeText: 'Animal',
      emoji: '🐾',
    ),
    Deck(
      id: DeckIds.dates,
      name: 'Dates',
      description: 'Time words for today, tomorrow, and more',
      badgeText: 'Date',
      emoji: '🗓️',
    ),
    Deck(
      id: DeckIds.nature,
      name: 'Nature',
      description: 'Weather, landscape, and the natural world',
      badgeText: 'Nature',
      emoji: '🌿',
    ),
  ];

  static Deck? byId(String id) {
    for (final deck in all) {
      if (deck.id == id) return deck;
    }
    return null;
  }
}
