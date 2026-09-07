import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external https links safely for Settings / support.
class UrlLaunchService {
  Future<bool> openHttpUrl(String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Failed to open URL: $e\n$st');
      }
      return false;
    }
  }
}

final urlLaunchServiceProvider = Provider<UrlLaunchService>((ref) {
  return UrlLaunchService();
});
