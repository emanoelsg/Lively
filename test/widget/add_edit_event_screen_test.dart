// test/widget/add_edit_event_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lively/models/event.dart';
import 'package:lively/providers/event_provider.dart';
import 'package:lively/screens/add_edit_event_screen.dart';
import '../helpers/test_setup.dart';

class MockEventNotifier extends Mock implements EventNotifier {
  @override
  EventState get state => const EventState(
        events: [],
        isLoading: false,
        totalSpent: 0.0,
      );
}

void main() {
  late MockEventNotifier mockEventNotifier;

  setUp(() async {
    mockEventNotifier = MockEventNotifier();
    await setupTestEnvironment();
  });

  tearDown(() async {
    await cleanupTestEnvironment();
  });

  group('AddEditEventScreen', () {
    testWidgets('can add new event', (tester) async {
      when(() => mockEventNotifier.addEvent(any(), any()))
          .thenAnswer((_) async {});

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

      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Event');
      await tester.enterText(find.byType(TextFormField).at(1), '100.00');

      // Submit form
      await tester.tap(find.text('Add Event'));
      await tester.pumpAndSettle();

      verify(() => mockEventNotifier.addEvent(any(), any())).called(1);
    });

    testWidgets('shows validation errors', (tester) async {
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

      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Add Event'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a name'), findsOneWidget);
      expect(find.text('Please enter a value'), findsOneWidget);
    });

    testWidgets('can edit existing event', (tester) async {
      final event = Event(id: 1, name: 'Test Event', value: 100.0);
      when(() => mockEventNotifier.updateEvent(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockEventNotifier.getEventById(any()))
          .thenAnswer((_) async => event);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventNotifierProvider.overrideWith((ref) => mockEventNotifier),
          ],
          child: MaterialApp(
            home: AddEditEventScreen(eventId: event.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if form is pre-filled
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('100.00'), findsOneWidget);

      // Update values
      await tester.enterText(find.byType(TextFormField).at(0), 'Updated Event');
      await tester.enterText(find.byType(TextFormField).at(1), '200.00');

      // Submit form
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      verify(() => mockEventNotifier.updateEvent(any(), any())).called(1);
    });
  });
}
