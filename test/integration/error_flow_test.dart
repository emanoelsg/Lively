// test/integration/error_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:lively/main.dart' as app;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../helpers/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('Error Handling Flow Tests', () {
    setUp(() async {
      await setupTestEnvironment();
    });

    tearDown(() async {
      await cleanupTestEnvironment();
    });

    testWidgets('Shows error for invalid event values', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to add an event with negative value
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test Event');
      await tester.enterText(find.byType(TextFormField).at(1), '-50.00');
      await tester.tap(find.text('Add Event'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Value must be greater than zero'), findsOneWidget);
    });

    testWidgets('Shows error for empty event fields', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to add an event with empty fields
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Event'));
      await tester.pumpAndSettle();

      // Verify error messages
      expect(find.text('Please enter a name'), findsOneWidget);
      expect(find.text('Please enter a value'), findsOneWidget);
    });

    testWidgets('Shows error for invalid budget value', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to set negative budget
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '-1000.00');
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Value must be greater than zero'), findsOneWidget);
    });

    testWidgets('Shows error for too large budget value', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to set extremely large budget
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '999999999999999.00');
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Value is too large'), findsOneWidget);
    });
  });
}