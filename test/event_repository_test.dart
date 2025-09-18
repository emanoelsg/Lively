// test/event_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/db/app_database.dart';
import 'package:lively/models/event.dart';
import 'package:lively/services/event_repository.dart';

class MockDatabase extends Mock implements Database {}
class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('EventRepository', () {
    late MockDatabase mockDb;
    late MockAppDatabase mockAppDb;
    late EventRepository repository;

    setUp(() {
      mockDb = MockDatabase();
      mockAppDb = MockAppDatabase();
      when(() => mockAppDb.database).thenAnswer((_) async => mockDb);
      repository = EventRepository(mockAppDb);
    });

    group('Error handling', () {
      test('handles database connection error', () async {
        // Arrange
        when(() => mockAppDb.database).thenThrow(Exception('Connection failed'));

        // Act & Assert
        expect(
          () => repository.getAllEvents(),
          throwsException,
        );
      });

      test('handles invalid SQL query', () async {
        // Arrange
        when(() => mockDb.query(any())).thenThrow(Exception('SQL error'));

        // Act & Assert
        expect(
          () => repository.getAllEvents(),
          throwsException,
        );
      });

      test('handles empty result set gracefully', () async {
        // Arrange
        when(() => mockDb.rawQuery(any())).thenAnswer((_) async => []);

        // Act
        final result = await repository.getTotalSpent();

        // Assert
        expect(result, 0.0);
      });
    });

    test('insertEvent should insert event into database', () async {
      // Arrange
      final event = Event(name: 'Test Event', value: 100.0);
      when(() => mockDb.insert(AppConstants.eventsTable, event.toMap()))
          .thenAnswer((_) async => 1);

      // Act
      final result = await repository.insertEvent(event);

      // Assert
      verify(() => mockDb.insert(AppConstants.eventsTable, event.toMap())).called(1);
      expect(result, 1);
    });

    test('getAllEvents should return list of events', () async {
      // Arrange
      final testEvents = [
        {'id': 1, 'name': 'Test 1', 'value': 100.0},
        {'id': 2, 'name': 'Test 2', 'value': 200.0},
      ];

      when(() => mockDb.query(
            AppConstants.eventsTable,
            orderBy: 'id ASC',
          )).thenAnswer((_) async => testEvents);

      // Act
      final result = await repository.getAllEvents();

      // Assert
      verify(() => mockDb.query(
            AppConstants.eventsTable,
            orderBy: 'id ASC',
          )).called(1);

      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].name, 'Test 1');
      expect(result[0].value, 100.0);
      expect(result[1].id, 2);
      expect(result[1].name, 'Test 2');
      expect(result[1].value, 200.0);
    });

    test('getTotalSpent should return correct sum', () async {
      // Arrange
      when(() => mockDb.rawQuery(any())).thenAnswer(
          (_) async => [{'total': 300.0}]);

      // Act
      final result = await repository.getTotalSpent();

      // Assert
      verify(() => mockDb.rawQuery(
            'SELECT COALESCE(SUM(value), 0.0) as total FROM ${AppConstants.eventsTable}',
          )).called(1);
      expect(result, 300.0);
    });
  });
}