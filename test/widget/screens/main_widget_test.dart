import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tedarikci_uygulamasi/main.dart';
import 'package:tedarikci_uygulamasi/screens/home_screen.dart';
import 'package:tedarikci_uygulamasi/screens/login_screen.dart';

void main() {
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
}