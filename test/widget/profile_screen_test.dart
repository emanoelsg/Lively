// test/widget/profile_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lively/screens/profile_screen.dart';
import '../helpers/test_setup.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  
  setUp(() async {
   
    await setupTestEnvironment();
  });

  tearDown(() async {
    await cleanupTestEnvironment();
  });

  group('ProfileScreen', () {
    testWidgets('saves nickname successfully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.tap(find.text('Save Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile saved'), findsOneWidget);
    });

    testWidgets('shows error on empty nickname', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Save Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a nickname'), findsOneWidget);
    });

  });
}