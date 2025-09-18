// test/integration/persistence_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:lively/main.dart' as app;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../helpers/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('App Persistence Tests', () {
    setUp(() async {
      await setupTestEnvironment();
    });

    tearDown(() async {
      await cleanupTestEnvironment();
    });

    testWidgets('Data persists after app restart', (tester) async {
      // First app launch
      app.main();
      await tester.pumpAndSettle();

      // Set initial budget
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1000.00');
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      // Add an event
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Event');
      await tester.enterText(find.byType(TextFormField).at(1), '50.00');
      await tester.tap(find.text('Add Event'));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('950.00'), findsOneWidget); // Remaining budget
      expect(find.text('50.00'), findsOneWidget); // Amount spent

      // Simulate app restart by rebuilding
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Verify data persisted
      expect(find.text('950.00'), findsOneWidget); // Remaining budget
      expect(find.text('50.00'), findsOneWidget); // Amount spent

      // Check history screen
      await tester.tap(find.byTooltip('History'));
      await tester.pumpAndSettle();
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);
    });
  });
}