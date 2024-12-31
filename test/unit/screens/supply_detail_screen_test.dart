import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../lib/screens/supply_detail_screen.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}

void main() {
  group('SupplyDetailScreen', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollectionReference;
    late MockDocumentReference mockDocumentReference;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();

      when(mockFirestore.collection('tedarikler')).thenReturn(mockCollectionReference as CollectionReference<Map<String, dynamic>>);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    });

    testWidgets('should display supply details and handle application',
            (WidgetTester tester) async {
          final supplyData = {
            'basvuranlar': ['testuser@example.com'],
            'kullanici': 'owner@example.com',
            'baslik': 'Test Tedarik',
            'aciklama': 'Test Aciklama',
            'fiyat': 500,
            'detayli_aciklama': 'Test Detaylı Açıklama',
            'imageUrl': 'https://example.com/image.jpg',
            'sektor': 'Yazılım',
          };

          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: SupplyDetailScreen(
                tedarik: supplyData,
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

          verify(mockDocumentReference.update(any)).called(1);
        });
  });
}