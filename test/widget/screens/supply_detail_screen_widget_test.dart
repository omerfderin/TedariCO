import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import '../../../lib/screens/supply_detail_screen.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  Map<String, dynamic> data() => _data;

  @override
  String get id => 'mockId';

  @override
  DocumentReference<Map<String, dynamic>> get reference => MockDocumentReference();
}

class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> update(Map<Object, Object?> data) async => Future.value();
}

void main() {
  group('SupplyDetailScreen Tests', () {
    testWidgets('SupplyDetailScreen renders and interacts correctly',
            (WidgetTester tester) async {
          final supplyData = {
            'baslik': 'Test Tedarik',
            'aciklama': 'Test Aciklama',
            'fiyat': 500,
            'detayli_aciklama': 'Test Detaylı Açıklama',
            'imageUrl': 'https://example.com/image.jpg',
            'sektor': 'Yazılım',
            'kullanici': 'owner@example.com',
            'basvuranlar': ['testuser@example.com'],
          };
          final currentUserEmail = 'testuser@example.com';
          final mockSnapshot = MockDocumentSnapshot(supplyData);

          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: SupplyDetailScreen(
                tedarik: mockSnapshot,
                currentUserEmail: currentUserEmail,
                toggleTheme: () {},
                isDarkMode: false,
              ),
            ),
          ));

          await tester.pumpAndSettle();

          expect(find.text('Tedarik Detayları'), findsOneWidget);
          expect(find.text('Test Tedarik'), findsOneWidget);
          expect(find.byType(Card), findsNWidgets(6));

          // Resme tıklama
          await tester.tap(find.byType(GestureDetector).first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.byType(Dialog), findsOneWidget);

          // Dialog'u kapat
          await tester.tapAt(const Offset(0, 0));
          await tester.pumpAndSettle();

          // Başvuru butonuna tıkla
          final button = find.byType(ElevatedButton).first;
          await tester.tap(button);
          await tester.pumpAndSettle();

          expect(find.byType(SnackBar), findsOneWidget);
        });
  });
}