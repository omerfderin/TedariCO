import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarikci_uygulamasi/screens/login_screen.dart';
// Mock Firebase Auth
class MockFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simüle edilmiş gecikme
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
    // Firebase.initializeApp() çağrısını mock'la
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
      // AppBar'daki "Giriş Yap" metnini bul
      expect(find.widgetWithText(AppBar, 'Giriş Yap'), findsOneWidget);
      // Diğer UI elemanları
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
          firebaseAuth: mockAuth, // Mock Firebase Auth'u enjekte et
        ),
      ));
      // Geçersiz bilgilerle giriş dene
      await tester.enterText(
          find.widgetWithText(TextField, 'E-posta'),
          'wrong@test.com'
      );
      await tester.enterText(
          find.widgetWithText(TextField, 'Şifre'),
          'wrongpass'
      );
      // Login butonuna tıkla
      await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
      // Firebase işleminin tamamlanmasını bekle
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      // Hata mesajını kontrol et
      expect(find.text('E-posta veya şifreniz yanlış.'), findsOneWidget);
    });
    testWidgets('loading durumu kontrolü', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(
          toggleTheme: () {},
          isDarkMode: false,
          firebaseAuth: mockAuth, // Mock Firebase Auth'u enjekte et
        ),
      ));
      // Geçerli bilgilerle giriş dene
      await tester.enterText(
          find.widgetWithText(TextField, 'E-posta'),
          'test@test.com'
      );
      await tester.enterText(
          find.widgetWithText(TextField, 'Şifre'),
          'password123'
      );
      // Login butonuna tıkla
      await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
      // İlk frame'i işle (loading göstergesi burada görünmeli)
      await tester.pump();
      // Loading göstergesi kontrolü
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // İşlemin tamamlanmasını bekle
      await tester.pumpAndSettle();
    });
  });
}
