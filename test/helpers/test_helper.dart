// test/helpers/test_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lively/l10n/app_localizations.dart';

/// Helper function to wrap a widget with necessary providers for testing
Widget makeTestableWidget(Widget child, {List<Override>? overrides}) {
  // No need to set up the environment here, it should be done in the test's setUp
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
      ],
    ),
  );
}

/// Extension method for easier testing of number formatting
extension PumpAndSettleWithTimeout on WidgetTester {
  Future<void> pumpAndSettleWithTimeout([Duration? timeout]) async {
    await pumpAndSettle(const Duration(milliseconds: 100));
  }
}

/// Helper function to enter text in a TextField or TextFormField
Future<void> enterTextInField(
  WidgetTester tester,
  String text,
  Finder finder,
) async {
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Helper function to tap a widget and wait for animations
Future<void> tapAndSettle(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}