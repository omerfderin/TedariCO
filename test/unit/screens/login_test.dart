import 'package:flutter_test/flutter_test.dart';
import 'package:tedarikci_uygulamasi/screens/login_screen.dart';

void main() {
  late LoginScreenState loginState;

  setUp(() {
    loginState = LoginScreenState();
  });

  group('LoginScreen Unit Tests', () {
    group('Email Validasyonu', () {
      test('geçerli email adresleri', () {
        expect(loginState.isValidEmail('test@test.com'), true);
        expect(loginState.isValidEmail('user.name@domain.com'), true);
        expect(loginState.isValidEmail('user123@sub.domain.com'), true);
      });

      test('geçersiz email adresleri', () {
        expect(loginState.isValidEmail(''), false);
        expect(loginState.isValidEmail('test'), false);
        expect(loginState.isValidEmail('test@'), false);
        expect(loginState.isValidEmail('test@domain'), false);
        expect(loginState.isValidEmail('@domain.com'), false);
      });
    });

    group('Şifre Validasyonu', () {
      test('geçerli şifreler (6 karakter veya daha uzun)', () {
        expect(loginState.isValidPassword('123456'), true);
        expect(loginState.isValidPassword('password123'), true);
        expect(loginState.isValidPassword('abc123xyz'), true);
      });

      test('geçersiz şifreler (6 karakterden kısa)', () {
        expect(loginState.isValidPassword(''), false);
        expect(loginState.isValidPassword('12345'), false);
        expect(loginState.isValidPassword('abc'), false);
      });
    });

    group('Form Validasyonu', () {
      test('geçerli form bilgileri', () {
        loginState.emailController.text = 'test@test.com';
        loginState.passwordController.text = '123456';
        expect(loginState.isValidForm(), true);
      });

      test('geçersiz form - boş alanlar', () {
        loginState.emailController.text = '';
        loginState.passwordController.text = '';
        expect(loginState.isValidForm(), false);
      });

      test('geçersiz form - hatalı email', () {
        loginState.emailController.text = 'invalid-email';
        loginState.passwordController.text = '123456';
        expect(loginState.isValidForm(), false);
      });

      test('geçersiz form - kısa şifre', () {
        loginState.emailController.text = 'test@test.com';
        loginState.passwordController.text = '12345';
        expect(loginState.isValidForm(), false);
      });
    });
  });
}