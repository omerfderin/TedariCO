// firebase_auth_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_auth_mock.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('Sign In Tests', () {
    test('successful sign in', () async {
      final result = await mockAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result.user, isNotNull);
      expect(result.user?.email, equals('test@test.com'));
      expect(result.user?.uid, equals('test-uid'));
      expect(mockAuth.currentUser, isNotNull);
    });

    test('sign in with wrong credentials throws exception', () async {
      expect(
            () => mockAuth.signInWithEmailAndPassword(
          email: 'wrong@test.com',
          password: 'wrongpass',
        ),
        throwsA(isA<FirebaseAuthException>().having(
              (e) => e.code,
          'code',
          'user-not-found',
        )),
      );
    });

    test('sign in with network error', () async {
      expect(
            () => mockAuth.signInWithEmailAndPassword(
          email: 'network@error.com',
          password: 'password123',
        ),
        throwsA(isA<FirebaseAuthException>().having(
              (e) => e.code,
          'code',
          'network-request-failed',
        )),
      );
    });
  });

  group('Sign Up Tests', () {
    test('successful sign up', () async {
      final result = await mockAuth.createUserWithEmailAndPassword(
        email: 'new@test.com',
        password: 'password123',
      );

      expect(result.user, isNotNull);
      expect(result.user?.email, equals('new@test.com'));
      expect(result.user?.emailVerified, isFalse);
    });

    test('sign up with existing email', () async {
      expect(
            () => mockAuth.createUserWithEmailAndPassword(
          email: 'existing@test.com',
          password: 'password123',
        ),
        throwsA(isA<FirebaseAuthException>().having(
              (e) => e.code,
          'code',
          'email-already-in-use',
        )),
      );
    });

    test('sign up with weak password', () async {
      expect(
            () => mockAuth.createUserWithEmailAndPassword(
          email: 'new@test.com',
          password: '123',
        ),
        throwsA(isA<FirebaseAuthException>().having(
              (e) => e.code,
          'code',
          'weak-password',
        )),
      );
    });
  });

  group('Password Reset Tests', () {
    test('successful password reset email', () async {
      await mockAuth.sendPasswordResetEmail(email: 'test@test.com');
      // Başarılı durumda exception fırlatılmamalı
    });

    test('password reset for non-existent user', () async {
      expect(
            () => mockAuth.sendPasswordResetEmail(email: 'nonexistent@test.com'),
        throwsA(isA<FirebaseAuthException>().having(
              (e) => e.code,
          'code',
          'user-not-found',
        )),
      );
    });
  });

  group('Auth State Tests', () {
    test('sign out clears current user', () async {
      // Önce giriş yapalım
      await mockAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password123',
      );
      expect(mockAuth.currentUser, isNotNull);

      // Çıkış yapalım
      await mockAuth.signOut();
      expect(mockAuth.currentUser, isNull);
    });

    test('auth state changes stream works', () async {
      final stream = mockAuth.authStateChanges();
      expect(stream, emits(null)); // Başlangıçta null

      // Giriş yapınca stream'den user gelmelidir
      await mockAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password123',
      );
      expect(mockAuth.authStateChanges(), emits(isNotNull));
    });
  });
}
