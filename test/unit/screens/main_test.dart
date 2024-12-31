import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tedarikci_uygulamasi/main.dart';
import 'package:tedarikci_uygulamasi/screens/home_screen.dart';
import 'package:tedarikci_uygulamasi/screens/login_screen.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp Test with Theme Toggle and Navigation', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);

      final userEmail = 'test@example.com';
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text(userEmail), findsOneWidget);
    });

    testWidgets('Initial theme should be light', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('Should persist theme selection', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Karanlık temaya geç
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();
      var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);

      // Aydınlık temaya geç
      await tester.tap(find.byIcon(Icons.light_mode));
      await tester.pump();
      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('Should show error on invalid navigation', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Geçersiz rota için Navigator'ı kullan
      final BuildContext context = tester.element(find.byType(MaterialApp));
      Navigator.pushNamed(context, '/invalid_route');
      await tester.pumpAndSettle();

      // Hata mesajını kontrol et
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('Should handle back navigation properly', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Ana sayfaya git
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Geri dön
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}