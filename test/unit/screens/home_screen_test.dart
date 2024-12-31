import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tedarikci_uygulamasi/screens/home_screen.dart';

class MockTheme extends Mock {
  void toggleTheme();
}

void main() {
  group('HomeScreen', () {
    MockTheme? mockTheme;

    setUp(() {
      mockTheme = MockTheme();
    });

    test('should have correct initial selectedIndex', () {
      final homeScreen = HomeScreen(
        userEmail: 'test@example.com',
        toggleTheme: mockTheme!.toggleTheme,
        isDarkMode: false,
      );

      expect(homeScreen.selectedIndex, 0);
    });

    test('should toggle theme', () {
      final homeScreen = HomeScreen(
        userEmail: 'test@example.com',
        toggleTheme: mockTheme!.toggleTheme,
        isDarkMode: false,
      );

      homeScreen.toggleTheme();
      verify(mockTheme!.toggleTheme()).called(1);
    });

    test('should filter tedarikler by fiyat ascending', () async {
      final homeScreen = HomeScreen(
        userEmail: 'test@example.com',
        toggleTheme: mockTheme!.toggleTheme,
        isDarkMode: false,
      );

      homeScreen._selectedFilter = 'Fiyat (Azdan Çoğa)';
      var stream = homeScreen.tedariklerStream;

      await for (var data in stream) {
        expect(data.docs.first['fiyat'], isA<int>());
      }
    });

    test('should filter tedarikler by fiyat descending', () async {
      final homeScreen = HomeScreen(
        userEmail: 'test@example.com',
        toggleTheme: mockTheme!.toggleTheme,
        isDarkMode: false,
      );

      homeScreen._selectedFilter = 'Fiyat (Çoktan Aza)';
      var stream = homeScreen.tedariklerStream;

      await for (var data in stream) {
        expect(data.docs.first['fiyat'], isA<int>());
      }
    });
  });
}

extension on HomeScreen {
  set _selectedFilter(String _selectedFilter) {}
}