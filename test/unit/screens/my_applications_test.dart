import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/my_applications.dart';
import 'package:tedarikci_uygulamasi/screens/supply_detail_screen.dart';

@GenerateMocks([])
class MockToggleTheme extends Mock {
  void call() {}
}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {
  @override
  Map<String, dynamic> data() => {
    'baslik': 'Test Baslik',
    'kullanici': 'Test Kullanici',
    'sektor': 'Sanayi',
    'aciklama': 'Test Açıklama',
    'fiyat': 100,
    'basvuranlar': ['testuser@example.com'],
  };
}

void main() {
  group('MyApplicationsScreen', () {
    late MockToggleTheme mockToggleTheme;
    final String userEmail = 'testuser@example.com';
    final bool isDarkMode = false;

    setUp(() {
      mockToggleTheme = MockToggleTheme();
    });

    testWidgets('should display loading indicator when data is waiting', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MyApplicationsScreen(
          userEmail: userEmail,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display no data message when no applications are found', (WidgetTester tester) async {
      final mockSnapshot = MockQuerySnapshot();
      when(mockSnapshot.docs).thenReturn([]);

      await tester.pumpWidget(MaterialApp(
        home: MyApplicationsScreen(
          userEmail: userEmail,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      await tester.pump();
      expect(find.text('Henüz başvuru yapmadınız'), findsOneWidget);
    });

    testWidgets('should navigate to SupplyDetailScreen on card tap', (WidgetTester tester) async {
      final mockDoc = MockQueryDocumentSnapshot();
      final mockSnapshot = MockQuerySnapshot();
      when(mockSnapshot.docs).thenReturn([mockDoc]);

      await tester.pumpWidget(MaterialApp(
        home: MyApplicationsScreen(
          userEmail: userEmail,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.byType(SupplyDetailScreen), findsOneWidget);
    });
  });
}