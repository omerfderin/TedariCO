import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tedarikci_uygulamasi/screens/share_screen.dart';

void main() {
  testWidgets('ShareScreen displays and interacts correctly', (WidgetTester tester) async {
    String userEmail = 'testuser@example.com';
    bool isDarkMode = false;
    final picker = ImagePicker();

    await tester.pumpWidget(MaterialApp(
      home: ShareScreen(
        userEmail: userEmail,
        toggleTheme: () {},
        isDarkMode: isDarkMode,
      ),
    ));

    expect(find.byType(TextField), findsNWidgets(4));

    await tester.tap(find.byIcon(Icons.photo));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.byType(Image), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Test Başlık');
    await tester.enterText(find.byType(TextField).at(1), 'Test Açıklama');
    await tester.enterText(find.byType(TextField).at(2), '200');
    await tester.enterText(find.byType(TextField).at(3), 'Detaylı Açıklama');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Tedarik başarıyla paylaşıldı!'), findsOneWidget);
  });
}