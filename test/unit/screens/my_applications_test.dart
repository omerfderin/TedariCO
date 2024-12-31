import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/my_applications.dart';

class MockToggleTheme extends Mock {
  void call();
}

void main() {
  group('MyApplicationsScreen', () {
    MockToggleTheme mockToggleTheme;
    String userEmail = 'testuser@example.com';
    bool isDarkMode = false;

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
      final mockSnapshot = Stream<QuerySnapshot>.value(QuerySnapshot(
        docs: [],
        metadata: SnapshotMetadata(isFromCache: false, hasPendingWrites: false),
      ));

      await tester.pumpWidget(MaterialApp(
        home: MyApplicationsScreen(
          userEmail: userEmail,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      expect(find.text('Henüz başvuru yapmadınız'), findsOneWidget);
    });

    testWidgets('should navigate to SupplyDetailScreen on card tap', (WidgetTester tester) async {
      final mockSnapshot = Stream<QuerySnapshot>.value(QuerySnapshot(
        docs: [
          {
            'baslik': 'Test Baslik',
            'kullanici': 'Test Kullanici',
            'sektor': 'IT',
            'aciklama': 'Test Açıklama',
            'fiyat': 100,
            'basvuranlar': [userEmail],
          }
        ].map((data) => FirebaseFirestore.instance.doc('/tedarikler/${data}')).toList(),
        metadata: SnapshotMetadata(isFromCache: false, hasPendingWrites: false),
      ));

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