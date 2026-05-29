import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/word.dart';

/// Loads bundled vocabulary JSON assets.
abstract final class VocabularyLoader {
  static const starterAssetPath = 'assets/data/starter_words.json';
  static const coreAssetPath = 'assets/data/core_welsh_words.json';
  static const topicAssetPath = 'assets/data/topic_decks_words.json';

  static Future<List<Word>> loadAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Word.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  static Future<List<Word>> loadAllBundled() async {
    final starter = await loadAsset(starterAssetPath);
    final core = await loadAsset(coreAssetPath);
    final topic = await loadAsset(topicAssetPath);
    return [...starter, ...core, ...topic];
  }
}
