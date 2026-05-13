import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:paned_app/app/paned_app.dart';
import 'package:paned_app/features/auth/domain/user_session.dart';
import 'package:paned_app/features/auth/presentation/providers/auth_session_provider.dart';

void main() {
  testWidgets('PanedApp mounts without Firebase when auth is overridden',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            (ref) => Stream<UserSession?>.value(null),
          ),
        ],
        child: const PanedApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
