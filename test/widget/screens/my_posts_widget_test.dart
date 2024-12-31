import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/my_posts.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, QuerySnapshot])
class MockFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      MockCollectionReference() as CollectionReference<Map<String, dynamic>>;
}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool? includeMetadataChanges,
    ListenSource? source,
  }) {
    return Stream.value(MockQuerySnapshot());
  }
}

class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {
  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => [MockDocumentSnapshot()];
}

class MockDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {
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

      when(mockFirestore.collection('tedarikler')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.snapshots(
        includeMetadataChanges: anyNamed('includeMetadataChanges'),
        source: anyNamed('source'),
      )).thenAnswer((_) => Stream.value(MockQuerySnapshot()));
    });

    testWidgets('MyPostsScreen displays posts correctly',
            (WidgetTester tester) async {
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