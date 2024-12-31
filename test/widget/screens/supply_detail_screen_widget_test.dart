import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../../lib/screens/supply_detail_screen.dart';

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

          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: SupplyDetailScreen(
                tedarik: supplyData,
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

          await tester.tap(find.byType(GestureDetector).first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.byType(Dialog), findsOneWidget);

          await tester.tap(find.byType(GestureDetector).first);
          await tester.pumpAndSettle();

          final button = find.byType(ElevatedButton).first;
          await tester.tap(button);
          await tester.pumpAndSettle();

          expect(find.byType(SnackBar), findsOneWidget);
        });
  });
}