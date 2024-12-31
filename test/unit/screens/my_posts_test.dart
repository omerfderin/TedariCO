import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/my_posts.dart';
import 'package:tedarikci_uygulamasi/screens/update_supply.dart';

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
    'basvuranlar': ['testuser@example.com'],
    'kullanici': 'testuser@example.com',
  };
}

void main() {
  group('MyPostsScreen', () {
    late MockToggleTheme mockToggleTheme;
    final String userEmail = 'testuser@example.com';
    final bool isDarkMode = false;

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
      final mockSnapshot = MockQuerySnapshot();
      when(mockSnapshot.docs).thenReturn([]);

      await tester.pumpWidget(MaterialApp(
        home: MyPostsScreen(
          userEmail: userEmail,
          toggleTheme: mockToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ));

      await tester.pump();
      expect(find.text('Henüz paylaşım yapmadınız'), findsOneWidget);
    });

    testWidgets('should navigate to UpdateSupply on card tap', (WidgetTester tester) async {
      final mockDoc = MockQueryDocumentSnapshot();
      final mockSnapshot = MockQuerySnapshot();
      when(mockSnapshot.docs).thenReturn([mockDoc]);

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