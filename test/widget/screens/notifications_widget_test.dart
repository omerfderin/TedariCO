import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../lib/screens/notifications.dart';

void main() {
  group('NotificationsScreen Widget Tests', () {
    testWidgets('loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(
            currentUserEmail: 'test@mail.com',
            toggleTheme: () {},
            isDarkMode: false,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(
            currentUserEmail: 'test@mail.com',
            toggleTheme: () {},
            isDarkMode: false,
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Henüz bildirim yok'), findsOneWidget);
    });
  });
}