import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/app/app.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';

void main() {
  testWidgets('Logged-out users land on the login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // No signed-in user; avoids touching real Firebase.
          authStateChangesProvider
              .overrideWith((ref) => Stream<User?>.value(null)),
        ],
        child: const StudioApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Auth gate sends unauthenticated users to the login screen, not the shell.
    expect(find.byKey(const Key('login-screen')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
