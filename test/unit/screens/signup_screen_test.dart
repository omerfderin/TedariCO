import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../lib/screens/signup_screen.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('SignupScreen', () {
    final mockAuth = MockFirebaseAuth();

    testWidgets('should show error if passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          toggleTheme: () {},
          isDarkMode: false,
        ),
      ));

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'differentpassword123');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Şifreler eşleşmiyor!'), findsOneWidget);
    });

    testWidgets('should handle FirebaseAuth exceptions correctly', (WidgetTester tester) async {
      when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email') ?? "a", password: anyNamed('password') ?? "b"))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          toggleTheme: () {},
          isDarkMode: false,
        ),
      ));

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'password123');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Bu e-posta adresi zaten kullanımda.'), findsOneWidget);
    });
  });
}