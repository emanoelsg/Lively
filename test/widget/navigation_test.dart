// test/widget/navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lively/main.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('Bottom navigation switches screens correctly',
        (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LivelyApp()));
      await tester.pumpAndSettle();

      // Start at home screen
      expect(find.text('Remaining'), findsOneWidget);

      // Navigate to history
      await tester.tap(find.byTooltip('History'));
      await tester.pumpAndSettle();
      expect(find.text('Event History'), findsOneWidget);

      // Navigate to profile
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byTooltip('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Remaining'), findsOneWidget);
    });

    testWidgets('FAB navigates to add event screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LivelyApp()));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify on add event screen
      expect(find.text('Add Event'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('Can navigate back from add event screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LivelyApp()));
      await tester.pumpAndSettle();

      // Go to add event screen
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify back on home screen
      expect(find.text('Remaining'), findsOneWidget);
    });

    testWidgets('Settings button navigates to settings screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LivelyApp()));
      await tester.pumpAndSettle();

      // Go to settings
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      // Verify on settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Monthly Budget'), findsOneWidget);
    });
  });
}