import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/paned_app.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/reminders/daily_reminder_bootstrap.dart';
import 'core/revenuecat/revenuecat_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await initializeRevenueCat();
  // Don't block first frame on notification plugin init (can stall on some devices).
  unawaited(initializeDailyReminder());
  runApp(const ProviderScope(child: PanedApp()));
}
