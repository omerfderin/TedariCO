import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email == 'test@test.com' && password == 'password123') {
      return Future.value(MockUserCredential());
    }
    throw FirebaseAuthException(
      code: 'user-not-found',
      message: 'E-posta veya şifreniz yanlış.',
    );
  }
}

class MockUserCredential extends Mock implements UserCredential {}