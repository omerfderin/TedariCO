import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MockFirebaseAuth {
  bool shouldSucceed = true;
  bool shouldThrowNetworkError = false;

  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrowNetworkError) {
      throw Exception('Bir ağ hatası oluştu.');
    }

    if (shouldSucceed && email == 'test@test.com' && password == 'password123') {
      return {
        'user': {
          'email': email,
          'uid': 'test-uid',
        }
      };
    }

    throw Exception('E-posta veya şifreniz yanlış.');
  }
}