import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/my_applications.dart';
import 'package:tedarikci_uygulamasi/screens/supply_detail_screen.dart';

class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {
  @override
  Map<String, dynamic> data() => {
    'baslik': 'Test Başlık',
    'kullanici': 'Kullanıcı 1',
    'sektor': 'Teknoloji',
    'aciklama': 'Açıklama',
    'fiyat': 150,
    'basvuranlar': ['test@example.com'],
  };
}

void main() {
  late MockQuerySnapshot mockSnapshot;
  late MockQueryDocumentSnapshot mockDoc;

  setUp(() {
    mockSnapshot = MockQuerySnapshot();
    mockDoc = MockQueryDocumentSnapshot();
    when(mockSnapshot.docs).thenReturn([mockDoc]);
  });

  testWidgets('MyApplicationsScreen displays applications and navigation works',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: MyApplicationsScreen(
              userEmail: 'test@example.com',
              toggleTheme: () {},
              isDarkMode: false,
            ),
          ),
        ));

        await tester.pumpAndSettle();

        expect(find.text('Test Başlık'), findsOneWidget);
        expect(find.text('Kullanıcı 1'), findsOneWidget);
        expect(find.text('Teknoloji'), findsOneWidget);

        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();
      });
}