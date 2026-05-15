import '../domain/deck.dart';
import '../domain/word.dart';

/// Starter deck sample words — not loaded from Excel.
abstract final class WordsData {
  static const List<Word> starterWords = [
    Word(
      id: 'starter_001',
      welsh: 'Helo',
      english: 'Hello',
      pronunciation: 'heh-loh',
      deckId: DeckIds.starterWords,
      deckName: 'Starter Words',
      badge: 'Starter Word',
      order: 1,
      emoji: '👋',
    ),
    Word(
      id: 'starter_002',
      welsh: 'Diolch',
      english: 'Thank you',
      pronunciation: 'dee-olkh',
      deckId: DeckIds.starterWords,
      deckName: 'Starter Words',
      badge: 'Starter Word',
      order: 2,
      emoji: '🙏',
    ),
    Word(
      id: 'starter_003',
      welsh: 'Bore da',
      english: 'Good morning',
      pronunciation: 'bo-reh dah',
      deckId: DeckIds.starterWords,
      deckName: 'Starter Words',
      badge: 'Starter Word',
      order: 3,
      emoji: '🌅',
    ),
    Word(
      id: 'starter_004',
      welsh: 'Nos da',
      english: 'Good night',
      pronunciation: 'nohs dah',
      deckId: DeckIds.starterWords,
      deckName: 'Starter Words',
      badge: 'Starter Word',
      order: 4,
      emoji: '🌙',
    ),
    Word(
      id: 'starter_005',
      welsh: 'Paned',
      english: 'Cup of tea',
      pronunciation: 'pah-ned',
      deckId: DeckIds.starterWords,
      deckName: 'Starter Words',
      badge: 'Starter Word',
      order: 5,
      emoji: '🍵',
    ),
  ];
}
