import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/profile_screen.dart';

class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {
  @override
  Map<String, dynamic> data() => {
    'baslik': 'Test Başlık',
    'aciklama': 'Açıklama',
    'fiyat': 200,
    'imageUrl': 'https://example.com/image.jpg',
    'sektor': 'Teknoloji',
    'kullanici': 'testuser@example.com',
  };
}

void main() {
  group('UserProfileScreen Tests', () {
    testWidgets('UserProfileScreen displays user data correctly',
            (WidgetTester tester) async {
          final mockQuerySnapshot = MockQuerySnapshot();
          final mockDoc = MockQueryDocumentSnapshot();

          when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: UserProfileScreen(
                userEmail: 'testuser@example.com',
                firebaseUser: 'firebaseTestUser',
                toggleTheme: () {},
                isDarkMode: false,
              ),
            ),
          ));

          await tester.pumpAndSettle();

          expect(find.text('testuser@example.com'), findsOneWidget);
          expect(find.text('Paylaşılan Tedarikler'), findsOneWidget);
        });
  });
}