import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/profile_screen.dart';
import 'package:tedarikci_uygulamasi/screens/supply_detail_screen.dart';

@GenerateMocks([])
class MockToggleTheme extends Mock {
  void call() {}
}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {
  @override
  Map<String, dynamic> data() => {
    'baslik': 'Test Başlık',
    'aciklama': 'Test Açıklama',
    'fiyat': 150,
    'imageUrl': 'https://example.com/image.jpg',
    'sektor': 'Teknoloji',
    'kullanici': 'testuser@example.com',
  };
}

void main() {
  group('UserProfileScreen', () {
    late MockToggleTheme mockToggleTheme;
    final String userEmail = 'testuser@example.com';
    final String firebaseUser = 'firebaseTestUser';
    final bool isDarkMode = false;

    setUp(() {
      mockToggleTheme = MockToggleTheme();
    });

    testWidgets('should display loading indicator when data is waiting', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserProfileScreen(
          userEmail: userEmail,
          firebaseUser: firebaseUser,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display user profile and navigate to SupplyDetailScreen on card tap', (WidgetTester tester) async {
      final mockDoc = MockQueryDocumentSnapshot();
      final mockSnapshot = MockQuerySnapshot();
      when(mockSnapshot.docs).thenReturn([mockDoc]);

      await tester.pumpWidget(MaterialApp(
        home: UserProfileScreen(
          userEmail: userEmail,
          firebaseUser: firebaseUser,
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