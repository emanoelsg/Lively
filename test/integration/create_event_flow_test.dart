// test/integration/create_event_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lively/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app test', () {
    testWidgets('Create event flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // First, set a budget since it's required
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), '1000.00');
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      // Navigate back and add an event
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill event form
      await tester.enterText(
          find.byType(TextFormField).first, 'Test Event');
      await tester.enterText(
          find.byType(TextFormField).at(1), '50.00');
      await tester.tap(find.text('Add Event'));
      await tester.pumpAndSettle();

      // Verify event appears in home screen
      expect(find.text('950.00'), findsOneWidget); // Remaining budget
      expect(find.text('Spent: 50.00'), findsOneWidget);

      // Go to history and verify event
      await tester.tap(find.byTooltip('History'));
      await tester.pumpAndSettle();

      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);
    });
  });
}