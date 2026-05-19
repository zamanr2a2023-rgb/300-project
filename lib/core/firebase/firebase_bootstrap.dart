import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

Future<void> initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) return;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase not configured: $e');
    }
    rethrow;
  }
}
