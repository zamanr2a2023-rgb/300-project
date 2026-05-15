import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speaks flashcard text in English or Welsh using device TTS.
class VocabularyTtsService {
  VocabularyTtsService() {
    _configure();
  }

  final FlutterTts _tts = FlutterTts();
  Future<void>? _configureFuture;
  String? _englishLocale;
  String? _welshLocale;

  static const _englishPreferred = ['en-GB', 'en_GB', 'en-US', 'en_US', 'en'];
  static const _welshPreferred = ['cy-GB', 'cy_GB', 'cy-WL', 'cy', 'welsh'];

  Future<void> _configure() {
    return _configureFuture ??= _configureImpl();
  }

  Future<void> _configureImpl() async {
    await _tts.setSpeechRate(kIsWeb ? 0.9 : 0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    if (!kIsWeb) {
      await _tts.awaitSpeakCompletion(true);
    }

    final languages = await _tts.getLanguages;
    if (languages is! List) return;

    final available = languages.map((e) => e.toString()).toList();
    _englishLocale = _pickLocale(available, _englishPreferred);
    _welshLocale = _pickLocale(available, _welshPreferred);
  }

  String? _pickLocale(List<String> available, List<String> preferred) {
    for (final code in preferred) {
      final match = available.where(
        (l) => l.toLowerCase().startsWith(code.toLowerCase()),
      );
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }

  Future<void> speakEnglish(String text) => _speak(text, _englishLocale);

  Future<void> speakWelsh(String text) => _speak(text, _welshLocale);

  Future<void> _speak(String text, String? locale) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _configure();
    await _tts.stop();
    if (locale != null) {
      await _tts.setLanguage(locale);
    }
    await _tts.speak(trimmed);
  }

  Future<void> stop() => _tts.stop();

  void dispose() {
    _tts.stop();
  }
}

final vocabularyTtsServiceProvider = Provider<VocabularyTtsService>((ref) {
  final service = VocabularyTtsService();
  ref.onDispose(service.dispose);
  return service;
});

/// @deprecated Use [vocabularyTtsServiceProvider].
@Deprecated('Use vocabularyTtsServiceProvider')
final welshTtsServiceProvider = vocabularyTtsServiceProvider;
