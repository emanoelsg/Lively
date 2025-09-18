// test/widget/add_event_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lively/providers/event_provider.dart';
import 'package:lively/screens/add_edit_event_screen.dart';

class MockEventNotifier extends Mock implements EventNotifier {}

void main() {
  late MockEventNotifier mockEventNotifier;

  setUp(() {
    mockEventNotifier = MockEventNotifier();
  });

  testWidgets('AddEditEventScreen validates form inputs',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockEventNotifier.state).thenReturn(
      const EventState(events: [], isLoading: false, totalSpent: 0),
    );

    // Act & Assert
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventNotifierProvider.overrideWith((ref) => mockEventNotifier),
        ],
        child: const MaterialApp(
          home: AddEditEventScreen(),
        ),
      ),
    );

    // Try to save without entering data
    await tester.tap(find.text('Add Event'));
    await tester.pumpAndSettle();

    // Verify validation errors are shown
    expect(find.text('Please enter a name'), findsOneWidget);
    expect(find.text('Please enter a value'), findsOneWidget);

    // Enter invalid value
    await tester.enterText(
        find.byType(TextFormField).at(1), '-10');
    await tester.tap(find.text('Add Event'));
    await tester.pumpAndSettle();

    expect(find.text('Value must be greater than zero'), findsOneWidget);

    // Enter valid data
    await tester.enterText(
        find.byType(TextFormField).first, 'Test Event');
    await tester.enterText(
        find.byType(TextFormField).at(1), '50.00');
    await tester.tap(find.text('Add Event'));
    await tester.pumpAndSettle();

    // Verify form submission
    verify(() => mockEventNotifier.addEvent(any())).called(1);
  });
}