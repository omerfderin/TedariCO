import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/my_posts.dart';
import 'package:tedarikci_uygulamasi/screens/update_supply.dart';

class MockToggleTheme extends Mock {
  void call();
}

void main() {
  group('MyPostsScreen', () {
    MockToggleTheme mockToggleTheme;
    String userEmail = 'testuser@example.com';
    bool isDarkMode = false;

    setUp(() {
      mockToggleTheme = MockToggleTheme();
    });

    testWidgets('should display loading indicator when data is waiting', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MyPostsScreen(
          userEmail: userEmail,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display no data message when no posts are found', (WidgetTester tester) async {
      final mockSnapshot = Stream<QuerySnapshot>.value(QuerySnapshot(
        docs: [],
        metadata: SnapshotMetadata(isFromCache: false, hasPendingWrites: false),
      ));

      await tester.pumpWidget(MaterialApp(
        home: MyPostsScreen(
          userEmail: userEmail,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      expect(find.text('Henüz paylaşım yapmadınız'), findsOneWidget);
    });

    testWidgets('should navigate to UpdateSupply on card tap', (WidgetTester tester) async {
      final mockTedarik = {
        'baslik': 'Test Başlık',
        'aciklama': 'Test Açıklama',
        'fiyat': 150,
        'imageUrl': 'https://example.com/image.jpg',
        'sektor': 'Teknoloji',
        'basvuranlar': ['testuser@example.com'],
        'kullanici': userEmail,
      };

      final mockSnapshot = Stream<QuerySnapshot>.value(QuerySnapshot(
        docs: [mockTedarik],
        metadata: SnapshotMetadata(isFromCache: false, hasPendingWrites: false),
      ));

      await tester.pumpWidget(MaterialApp(
        home: MyPostsScreen(
          userEmail: userEmail,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.byType(UpdateSupply), findsOneWidget);
    });
  });
}