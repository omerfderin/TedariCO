import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:tedarikci_uygulamasi/screens/home_screen.dart';

class MockTheme extends Mock {
  void toggleTheme();
}

void main() {
  group('HomeScreen Widget', () {
    late MockTheme mockTheme;

    setUp(() {
      mockTheme = MockTheme();
    });

    testWidgets('should display notifications icon with unread count', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen(
        userEmail: 'test@example.com',
        toggleTheme: mockTheme.toggleTheme,
        isDarkMode: false,
      )));

      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('should toggle between light and dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen(
        userEmail: 'test@example.com',
        toggleTheme: mockTheme.toggleTheme,
        isDarkMode: false,
      )));

      expect(find.byIcon(Icons.light_mode), findsOneWidget);

      await tester.tap(find.byIcon(Icons.light_mode));
      await tester.pump();

      verify(mockTheme.toggleTheme()).called(1);
    });

    testWidgets('should display correct navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen(
        userEmail: 'test@example.com',
        toggleTheme: mockTheme.toggleTheme,
        isDarkMode: false,
      )));

      expect(find.text('Ana Akış'), findsOneWidget);
      expect(find.text('Tedarik Ekle'), findsOneWidget);
      expect(find.text('Paylaşımlarım'), findsOneWidget);
    });
  });
}