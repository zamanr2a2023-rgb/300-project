import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/deck.dart';
import '../domain/word.dart';

/// Loads buyer vocabulary from bundled JSON.
abstract final class CoreWordsLoader {
  static const assetPath = 'assets/data/core_welsh_words.json';

  static Future<List<Word>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Word.fromJson(e as Map<String, dynamic>))
        .where((w) => w.deckId == DeckIds.coreWelshWords)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}
