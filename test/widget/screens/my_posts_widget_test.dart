import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/my_posts.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockDocumentSnapshot extends Mock implements QueryDocumentSnapshot {
  @override
  Map<String, dynamic> data() => {
    'baslik': 'Test Başlık',
    'aciklama': 'Açıklama',
    'fiyat': 200,
    'imageUrl': 'https://example.com/image.jpg',
    'sektor': 'Sektör',
    'basvuranlar': ['test@example.com'],
    'kullanici': 'test@example.com',
  };
}

void main() {
  group('MyPostsScreen Tests', () {
    late MockFirestore mockFirestore;
    late MockCollectionReference mockCollectionReference;

    setUp(() {
      mockFirestore = MockFirestore();
      mockCollectionReference = MockCollectionReference();
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
    });

    testWidgets('MyPostsScreen displays posts correctly',
            (WidgetTester tester) async {
          final mockQuerySnapshot = MockQuerySnapshot();
          final mockDoc = MockDocumentSnapshot();

          when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: MyPostsScreen(
                userEmail: 'test@example.com',
                toggleTheme: () {},
                isDarkMode: false,
              ),
            ),
          ));

          await tester.pumpAndSettle();

          expect(find.text('Test Başlık'), findsOneWidget);
          expect(find.text('Açıklama'), findsOneWidget);
          expect(find.text('200₺'), findsOneWidget);
        });
  });
}