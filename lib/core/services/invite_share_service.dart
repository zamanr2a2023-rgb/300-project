import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_share_config.dart';

/// Opens the platform share sheet for inviting friends (no referral tracking).
class InviteShareService {
  Future<void> shareInvite() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: AppShareConfig.inviteMessage,
          subject: AppShareConfig.inviteSubject,
        ),
      );
    } catch (e, st) {
      // User dismissing the sheet is not an error; only log unexpected failures.
      if (kDebugMode) {
        debugPrint('Invite share failed: $e\n$st');
      }
    }
  }
}

final inviteShareServiceProvider = Provider<InviteShareService>((ref) {
  return InviteShareService();
});
