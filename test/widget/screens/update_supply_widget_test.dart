import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../lib/screens/update_supply.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  @override
  Map<String, dynamic> data() => {
    'baslik': 'Test Title',
    'aciklama': 'Test Description',
    'fiyat': 100.0,
    'detayli_aciklama': 'Test Detailed Description',
  };
}

void main() {
  testWidgets('should display UpdateSupply screen with correct elements',
          (WidgetTester tester) async {

        final mockDocument = MockDocumentSnapshot();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UpdateSupply(
                tedarik: mockDocument,
                userEmail: 'test@example.com',
                toggleTheme: () {},
                isDarkMode: false,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Tedarik Başlığı'), findsOneWidget);
        expect(find.text('Tedarik Açıklaması'), findsOneWidget);
        expect(find.text('Fiyat (₺)'), findsOneWidget);
        expect(find.text('Detaylı Açıklama'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4));
        expect(find.byType(ElevatedButton), findsNWidgets(3));
      });
}