import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/words_repository.dart';

final wordsRepositoryProvider = Provider<WordsRepository>((ref) {
  return WordsRepository();
});

final wordsCatalogProvider = FutureProvider<WordsCatalog>((ref) async {
  return ref.read(wordsRepositoryProvider).loadCatalog();
});
