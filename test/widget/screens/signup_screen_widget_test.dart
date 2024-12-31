import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../../lib/screens//signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  testWidgets('SignupScreen renders and interacts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignupScreen(
        toggleTheme: () {},
        isDarkMode: false,
      ),
    ));

    // Verify initial UI components
    expect(find.text('Yeni Hesap Oluştur'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Test form field input
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.enterText(find.byType(TextField).at(2), 'password123');

    // Test form submission
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Expect navigation or error message
    expect(find.text('Bir hata oluştu:'), findsOneWidget);

    // Change theme and check icon
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pump();
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}