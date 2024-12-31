import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../lib/screens/supply_detail_screen.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference])
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      MockCollectionReference() as CollectionReference<Map<String, dynamic>>;
}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      MockDocumentReference() as DocumentReference<Map<String, dynamic>>;
}

class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> update(Map<Object, Object?> data) async {
    return Future.value();
  }
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  Map<String, dynamic> data() => _data;

  @override
  String get id => 'mockDocId';

  @override
  DocumentReference<Map<String, dynamic>> get reference => MockDocumentReference();
}

void main() {
  group('SupplyDetailScreen', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollectionReference;
    late MockDocumentReference mockDocumentReference;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();

      when(mockFirestore.collection('tedarikler')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.update({'basvuranlar': any})).thenAnswer((_) async => {});
    });

    testWidgets('should display supply details and handle application',
            (WidgetTester tester) async {
          final Map<String, dynamic> supplyData = {
            'basvuranlar': ['testuser@example.com'],
            'kullanici': 'owner@example.com',
            'baslik': 'Test Tedarik',
            'aciklama': 'Test Aciklama',
            'fiyat': 500,
            'detayli_aciklama': 'Test Detaylı Açıklama',
            'imageUrl': 'https://example.com/image.jpg',
            'sektor': 'Yazılım',
            'id': 'mockDocId'
          };

          final mockSnapshot = MockDocumentSnapshot(supplyData);

          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: SupplyDetailScreen(
                tedarik: mockSnapshot,
                currentUserEmail: 'testuser@example.com',
                toggleTheme: () {},
                isDarkMode: false,
              ),
            ),
          ));

          await tester.pumpAndSettle();

          expect(find.text('Test Tedarik'), findsOneWidget);
          expect(find.text('Test Aciklama'), findsOneWidget);

          await tester.tap(find.byType(ElevatedButton).first);
          await tester.pumpAndSettle();

          verify(mockDocumentReference.update({'basvuranlar': []})).called(1);
        });
  });
}