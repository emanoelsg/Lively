// test/integration/main_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lively/main.dart' as app;
import '../helpers/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app flow', () {
    testWidgets('Complete user journey', (tester) async {
      await setupTestEnvironment();
      app.main();
      await tester.pumpAndSettle();

      // Initial budget setup
      expect(find.text('Set Your Monthly Budget'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Add first expense
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_name_field')), 
        'Groceries'
      );
      await tester.enterText(
        find.byKey(const Key('event_value_field')), 
        '50.00'
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify expense in home screen
      expect(find.text('950.00'), findsOneWidget); // Remaining budget
      expect(find.text('50.00'), findsOneWidget); // Spent amount

      // View history
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);

      // Edit profile
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test User');
      await tester.tap(find.text('Save Profile'));
      await tester.pumpAndSettle();

      // Back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify profile update
      expect(find.text('Welcome, Test User!'), findsOneWidget);

      await cleanupTestEnvironment();
    });
  });
}