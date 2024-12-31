import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarikci_uygulamasi/screens/login_screen.dart';

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    if (email == 'test@test.com' && password == 'password123') {
      return MockUserCredential();
    }
    throw FirebaseAuthException(
      code: 'user-not-found',
      message: 'E-posta veya şifreniz yanlış.',
    );
  }
}

class MockUserCredential extends Fake implements UserCredential {
  @override
  User? get user => MockUser();
}

class MockUser extends Fake implements User {
  @override
  String? get email => 'test@test.com';
}

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Login Screen Widget Tests', () {
    testWidgets('UI elemanları kontrolü', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(
          toggleTheme: () {},
          isDarkMode: false,
        ),
      ));

      expect(find.widgetWithText(AppBar, 'Giriş Yap'), findsOneWidget);
      expect(find.text('Hoş geldiniz!'), findsOneWidget);
      expect(find.text('Lütfen e-posta ve şifrenizi girerek devam edin.'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'E-posta'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Şifre'), findsOneWidget);
    });

    testWidgets('başarısız login senaryosu', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(
          toggleTheme: () {},
          isDarkMode: false,
          firebaseAuth: mockAuth,
        ),
      ));

      await tester.enterText(
          find.widgetWithText(TextField, 'E-posta'),
          'wrong@test.com'
      );
      await tester.enterText(
          find.widgetWithText(TextField, 'Şifre'),
          'wrongpass'
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('E-posta veya şifreniz yanlış.'), findsOneWidget);
    });

    testWidgets('loading durumu kontrolü', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(
          toggleTheme: () {},
          isDarkMode: false,
          firebaseAuth: mockAuth,
        ),
      ));

      await tester.enterText(
          find.widgetWithText(TextField, 'E-posta'),
          'test@test.com'
      );
      await tester.enterText(
          find.widgetWithText(TextField, 'Şifre'),
          'password123'
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}