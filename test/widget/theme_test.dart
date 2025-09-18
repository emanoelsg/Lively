// test/widget/theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lively/main.dart';
import 'package:lively/core/theme.dart';

void main() {
  group('Theme Tests', () {
    testWidgets('app starts with light theme', (tester) async {
      await tester.pumpWidget(const LivelyApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      expect(Theme.of(context).brightness, equals(Brightness.light));
      expect(Theme.of(context).colorScheme.primary, equals(AppTheme.primaryColor));
    });

    testWidgets('app supports dark theme', (tester) async {
      await tester.pumpWidget(const LivelyApp());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      
      // Simulate dark mode by providing custom MediaQuery
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(platformBrightness: Brightness.dark),
          child: LivelyApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(Theme.of(context).brightness, equals(Brightness.dark));
      expect(Theme.of(context).scaffoldBackgroundColor, equals(Colors.black));
      expect(Theme.of(context).cardColor, equals(AppTheme.darkCardColor));
    });

    testWidgets('app theme colors are consistent', (tester) async {
      await tester.pumpWidget(const LivelyApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      final theme = Theme.of(context);

      // Light theme checks
      expect(theme.colorScheme.primary, equals(AppTheme.primaryColor));
      expect(theme.cardColor, equals(AppTheme.lightCardColor));

      // Simulate dark mode by providing custom MediaQuery
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(platformBrightness: Brightness.dark),
          child: LivelyApp(),
        ),
      );
      await tester.pumpAndSettle();

      final darkTheme = Theme.of(context);
      expect(darkTheme.colorScheme.primary, equals(AppTheme.primaryColor));
      expect(darkTheme.cardColor, equals(AppTheme.darkCardColor));
    });
  });
}