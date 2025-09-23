// test/widget/config_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lively/providers/budget_provider.dart';
import 'package:lively/screens/config_screen.dart';
import '../helpers/test_setup.dart';

class MockBudgetNotifier extends Mock implements BudgetNotifier {
  @override
  BudgetState get state => const BudgetState(
        budget: 1000.0,
        remainingBudget: 800.0,
        isLoading: false,
      );
}

void main() {
  late MockBudgetNotifier mockBudgetNotifier;

  setUp(() async {
    mockBudgetNotifier = MockBudgetNotifier();
    await setupTestEnvironment();
  });

  tearDown(() async {
    await cleanupTestEnvironment();
  });

  group('ConfigScreen', () {
    testWidgets('shows current budget', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
          ],
          child: const MaterialApp(
            home: ConfigScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('R\$ 1,000.00'), findsOneWidget);
    });

    testWidgets('can update budget', (tester) async {
      when(() => mockBudgetNotifier.setBudget(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
          ],
          child: const MaterialApp(
            home: ConfigScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Enter new budget in dialog
      await tester.enterText(find.byType(TextField), '2000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => mockBudgetNotifier.setBudget(2000.0)).called(1);
    });

    testWidgets('shows error for invalid budget', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
          ],
          child: const MaterialApp(
            home: ConfigScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Try to save invalid budget
      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid budget.'), findsOneWidget);
    });
  });
}