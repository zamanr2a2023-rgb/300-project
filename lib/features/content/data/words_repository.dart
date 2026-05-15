import '../domain/word.dart';
import 'core_words_loader.dart';
import 'words_data.dart';

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
    final core = await CoreWordsLoader.load();
    _cache = [...core, ...WordsData.starterWords];
    return WordsCatalog(all: _cache!);
  }
}
