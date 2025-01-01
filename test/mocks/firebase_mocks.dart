// firebase_auth_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './firebase_auth_mock.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('Password Reset Tests', () {
    test('successful password reset email', () async {
      // Geçerli e-posta için hata vermemeli
      await expectLater(
        mockAuth.sendPasswordResetEmail(email: 'test@test.com'),
        completes,
      );
    });

    test('empty email throws exception', () async {
      expect(
            () => mockAuth.sendPasswordResetEmail(email: ''),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'invalid-email')
            .having((e) => e.message, 'message', 'E-posta adresi boş olamaz.')),
      );
    });

    test('invalid email format throws exception', () async {
      expect(
            () => mockAuth.sendPasswordResetEmail(email: 'invalid-email'),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'invalid-email')
            .having((e) => e.message, 'message', 'Geçersiz e-posta formatı.')),
      );
    });

    test('non-existent user throws exception', () async {
      expect(
            () => mockAuth.sendPasswordResetEmail(email: 'nonexistent@test.com'),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'user-not-found')
            .having(
              (e) => e.message,
          'message',
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
        )),
      );
    });
  });
}
