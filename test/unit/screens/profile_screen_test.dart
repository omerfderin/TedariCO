import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/profile_screen.dart';
import 'package:tedarikci_uygulamasi/screens/supply_detail_screen.dart';

class MockToggleTheme extends Mock {
  void call();
}

void main() {
  group('UserProfileScreen', () {
    MockToggleTheme mockToggleTheme;
    String userEmail = 'testuser@example.com';
    String firebaseUser = 'firebaseTestUser';
    bool isDarkMode = false;

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
      final mockSnapshot = Stream<QuerySnapshot>.value(QuerySnapshot(
        docs: [
          {
            'baslik': 'Test Başlık',
            'aciklama': 'Test Açıklama',
            'fiyat': 150,
            'imageUrl': 'https://example.com/image.jpg',
            'sektor': 'Teknoloji',
            'kullanici': userEmail,
          }
        ].map((data) => FirebaseFirestore.instance.doc('/tedarikler/${data}')).toList(),
        metadata: SnapshotMetadata(isFromCache: false, hasPendingWrites: false),
      ));

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