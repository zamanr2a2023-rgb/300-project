import '../domain/word.dart';
import 'vocabulary_loader.dart';

class WordsCatalog {
  const WordsCatalog({required this.all});

  final List<Word> all;

  List<Word> forDeck(String deckId) =>
      all.where((w) => w.deckId == deckId).toList();
}

class WordsRepository {
  List<Word>? _cache;

  Future<WordsCatalog> loadCatalog() async {
    if (_cache != null) {
      return WordsCatalog(all: _cache!);
    }
    _cache = await VocabularyLoader.loadAllBundled();
    return WordsCatalog(all: _cache!);
  }
}
