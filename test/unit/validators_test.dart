// test/unit/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lively/models/event.dart';

void main() {
  group('Event Validation', () {
    test('name should not be empty', () {
      expect(() => Event(name: '', value: 10.0), throwsAssertionError);
    });

    test('value validation', () {
      final event = Event(name: 'Test', value: 10.0);
      expect(event.value, isPositive);
      expect(event.value.isFinite, isTrue);
    });

    test('value should be positive', () {
      expect(() => Event(name: 'Test', value: -10.0), throwsAssertionError);
    });

    test('value should not be too large', () {
      expect(
        () => Event(name: 'Test', value: double.maxFinite),
        throwsAssertionError,
      );
    });

    test('valid event should be created', () {
      final event = Event(name: 'Test', value: 10.0);
      expect(event.name, 'Test');
      expect(event.value, 10.0);
    });
  });
}