import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../lib/screens/update_supply.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  @override
  String get id => 'mockId';

  @override
  Map<String, dynamic> data() => {
    'baslik': 'Test Title',
    'aciklama': 'Test Description',
    'fiyat': 100.0,
    'detayli_aciklama': 'Test Detailed Description',
  };
}

void main() {
  group('UpdateSupplyState', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollectionReference;
    late MockDocumentReference mockDocumentReference;
    late MockDocumentSnapshot mockDocument;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();
      mockDocument = MockDocumentSnapshot();

      when(mockFirestore.collection('tedarikler')).thenReturn(mockCollectionReference as CollectionReference<Map<String, dynamic>>);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    });

    testWidgets('should update tedarik when valid data is provided',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: UpdateSupply(
                tedarik: mockDocument,
                userEmail: 'test@example.com',
                toggleTheme: () {},
                isDarkMode: false,
              ),
            ),
          );

          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextFormField).at(0), 'Updated Title');
          await tester.enterText(find.byType(TextFormField).at(1), 'Updated Description');
          await tester.enterText(find.byType(TextFormField).at(2), '200');
          await tester.enterText(find.byType(TextFormField).at(3), 'Updated Detailed Description');

          await tester.tap(find.byType(ElevatedButton).first);
          await tester.pumpAndSettle();

          verify(mockDocumentReference.update(any)).called(1);
        });

    testWidgets('should delete tedarik when confirmation is given',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: UpdateSupply(
                tedarik: mockDocument,
                userEmail: 'test@example.com',
                toggleTheme: () {},
                isDarkMode: false,
              ),
            ),
          );

          await tester.pumpAndSettle();
          await tester.tap(find.byType(ElevatedButton).last);
          await tester.pumpAndSettle();

          expect(find.text('Silme Onayı'), findsOneWidget);
          await tester.tap(find.text('Evet'));
          await tester.pumpAndSettle();

          verify(mockDocumentReference.delete()).called(1);
        });
  });
}