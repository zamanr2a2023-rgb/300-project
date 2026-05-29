/// Stable deck identifiers used across UI, routing, and word assignment.
abstract final class DeckIds {
  static const starterWords = 'starter_words';
  static const coreWelshWords = 'core_welsh_words';
  static const daysAndMonths = 'days_and_months';
  static const phrases = 'phrases';
  static const talkingAboutMe = 'talking_about_me';
  static const animals = 'animals';
  static const dates = 'dates';
  static const nature = 'nature';
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
