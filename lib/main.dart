import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/paned_app.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/revenuecat/revenuecat_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await initializeRevenueCat();
  runApp(const ProviderScope(child: PanedApp()));
}
