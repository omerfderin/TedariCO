import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tedarikci_uygulamasi/main.dart';
import 'package:tedarikci_uygulamasi/screens/home_screen.dart';

// Mock sınıfı
class MockTheme extends Mock {
  void toggleTheme();
}

void main() {
  group('MyApp', () {
    MockTheme? mockTheme;

    setUp(() {
      mockTheme = MockTheme();
    });

    testWidgets('Initial Theme is Light', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);
    });

    testWidgets('Toggle Theme to Dark', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        toggleTheme: mockTheme!.toggleTheme,
        isDarkMode: false, // Başlangıçta açık mod
      ));

      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pumpAndSettle(); // Animasyonların tamamlanmasını bekle
      verify(mockTheme!.toggleTheme()).called(1);
    });

    testWidgets('Toggle Theme to Light', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        toggleTheme: mockTheme!.toggleTheme,
        isDarkMode: true, // Başlangıçta koyu mod
      ));

      await tester.tap(find.byIcon(Icons.light_mode));
      await tester.pumpAndSettle(); // Animasyonların tamamlanmasını bekle
      verify(mockTheme!.toggleTheme()).called(1);
    });

    testWidgets('Navigate to HomeScreen with Arguments', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MyApp(),
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            return MaterialPageRoute(
              builder: (context) => HomeScreen(
                userEmail: 'test@example.com',
                toggleTheme: () {},
                isDarkMode: false,
              ),
            );
          }
          return null;
        },
      ));

      await tester.pumpAndSettle();

      final homeScreen = find.byType(HomeScreen);
      expect(homeScreen, findsOneWidget);
    });
  });
}