import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tedarikci_uygulamasi/screens/share_screen.dart';
import 'dart:io';

class MockImagePicker extends Mock implements ImagePicker {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class FakeReference extends Mock implements Reference {}
class FakeCollectionReference extends Mock implements CollectionReference {}

void main() {
  group('ShareScreen', () {
    final mockPicker = MockImagePicker();
    final mockStorage = MockFirebaseStorage();
    final mockFirestore = MockFirebaseFirestore();
    String userEmail = 'testuser@example.com';
    bool isDarkMode = false;

    setUp(() {
      when(mockPicker.pickImage(source: anyNamed('source'))).thenAnswer((_) async => XFile('path/to/test/image.jpg'));
      when(mockStorage.ref().child(any)).thenReturn(FakeReference());
      when(mockFirestore.collection(any)).thenReturn(FakeCollectionReference());
    });

    testWidgets('should display an error if any field is empty', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ShareScreen(
          userEmail: userEmail,
          toggleTheme: () {},
          isDarkMode: isDarkMode,
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Lütfen tüm alanları doldurun ve bir görsel seçin!'), findsOneWidget);
    });

    testWidgets('should share the tedarik successfully', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ShareScreen(
          userEmail: userEmail,
          toggleTheme: () {},
          isDarkMode: isDarkMode,
        ),
      ));

      await tester.enterText(find.byType(TextField).first, 'Test Başlık');
      await tester.enterText(find.byType(TextField).at(1), 'Test Açıklama');
      await tester.enterText(find.byType(TextField).at(2), '150');
      await tester.enterText(find.byType(TextField).at(3), 'Detaylı Açıklama');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Tedarik başarıyla paylaşıldı!'), findsOneWidget);
    });
  });
}