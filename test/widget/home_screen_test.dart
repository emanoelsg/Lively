// test/widget/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lively/providers/budget_provider.dart';
import 'package:lively/providers/event_provider.dart';
import 'package:lively/screens/home_screen.dart';
import '../helpers/test_setup.dart';
import '../helpers/test_helper.dart';

// Create mocks for providers
class MockBudgetNotifier extends Mock implements BudgetNotifier {
  @override
  BudgetState get state => const BudgetState(
        budget: 1000.0,
        remainingBudget: 800.0,
        isLoading: false,
      );
}

class MockEventNotifier extends Mock implements EventNotifier {
  @override
  EventState get state => const EventState(
        events: [],
        isLoading: false,
        totalSpent: 200.0,
      );
}

void main() {
  late MockBudgetNotifier mockBudgetNotifier;
  late MockEventNotifier mockEventNotifier;

  setUp(() {
    mockBudgetNotifier = MockBudgetNotifier();
    mockEventNotifier = MockEventNotifier();
  });

  group('HomeScreen widget tests', () {
    testWidgets('displays budget donut and FAB with remaining budget',
        (WidgetTester tester) async {
      await setupTestEnvironment();
      await tester.pumpWidget(makeTestableWidget(
        const HomeScreen(),
        overrides: [
          budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
          eventNotifierProvider.overrideWith((ref) => mockEventNotifier),
        ],
      ));

      await tester.pumpAndSettle();

      // Verify the FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Verify the donut chart shows the budget amount
      expect(find.text('800.00'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
    });

    testWidgets('displays budget donut with 50% spent',
        (WidgetTester tester) async {
      when(() => mockBudgetNotifier.state).thenReturn(const BudgetState(
        budget: 1000.0,
        remainingBudget: 500.0,
        isLoading: false,
      ));
      when(() => mockEventNotifier.state).thenReturn(const EventState(
        events: [],
        isLoading: false,
        totalSpent: 500.0,
      ));
      
      await setupTestEnvironment();
      await tester.pumpWidget(makeTestableWidget(
        const HomeScreen(),
        overrides: [
          budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
          eventNotifierProvider.overrideWith((ref) => mockEventNotifier),
        ],
      ));

      await tester.pumpAndSettle();

      // Verify the donut chart shows 50% spent
      expect(find.text('500.00'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
    });

    testWidgets('displays budget donut with 100% spent',
        (WidgetTester tester) async {
      when(() => mockBudgetNotifier.state).thenReturn(const BudgetState(
        budget: 1000.0,
        remainingBudget: 0.0,
        isLoading: false,
      ));
      when(() => mockEventNotifier.state).thenReturn(const EventState(
        events: [],
        isLoading: false,
        totalSpent: 1000.0,
      ));

      await setupTestEnvironment();
      await tester.pumpWidget(makeTestableWidget(
        const HomeScreen(),
        overrides: [
          budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
          eventNotifierProvider.overrideWith((ref) => mockEventNotifier),
        ],
      ));

      await tester.pumpAndSettle();

      // Verify the donut chart shows 0 remaining
      expect(find.text('0.00'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
    });

    testWidgets('navigates to add event screen when FAB is tapped',
        (WidgetTester tester) async {
      await setupTestEnvironment();
      await tester.pumpWidget(makeTestableWidget(
        const HomeScreen(),
        overrides: [
          budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
          eventNotifierProvider.overrideWith((ref) => mockEventNotifier),
        ],
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify navigation (assuming AddEventScreen uses a Scaffold)
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Add Event'), findsOneWidget);
    });
  });
}