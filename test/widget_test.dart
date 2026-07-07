import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/app/app.dart';

void main() {
  testWidgets('App boots into the shell with bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: StudioApp()));
    await tester.pumpAndSettle();

    // The five-tab bottom navigation renders.
    expect(find.byType(NavigationBar), findsOneWidget);
    // Home tab is the initial route.
    expect(find.byType(Scaffold), findsWidgets);
  });
}
