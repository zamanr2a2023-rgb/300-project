import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../content/domain/deck.dart';

/// Active deck for the Learn (swipe) tab.
final selectedDeckIdProvider = StateProvider<String>(
  (ref) => DeckIds.starterWords,
);
