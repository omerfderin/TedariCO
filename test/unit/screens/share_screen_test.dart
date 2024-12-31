import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tedarikci_uygulamasi/screens/share_screen.dart';
import 'dart:io';

@GenerateMocks([ImagePicker, FirebaseStorage, FirebaseFirestore, Reference, CollectionReference])
class MockImagePicker extends Mock implements ImagePicker {
  @override
  Future<XFile?> pickImage({
    ImageSource? source,
    int? imageQuality,
    double? maxHeight,
    double? maxWidth,
    CameraDevice? preferredCameraDevice,
    bool? requestFullMetadata,
  }) async {
    return XFile('path/to/test/image.jpg');
  }
}

class MockFirebaseStorage extends Mock implements FirebaseStorage {
  @override
  Reference ref([String? path]) => MockReference();
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      MockCollectionReference() as CollectionReference<Map<String, dynamic>>;
}

class MockReference extends Mock implements Reference {
  @override
  Reference child(String path) => this;
}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {
  @override
  Future<DocumentReference<Map<String, dynamic>>> add(Map<String, dynamic>? data) async {
    return MockDocumentReference() as DocumentReference<Map<String, dynamic>>;
  }
}

class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('ShareScreen', () {
    late MockImagePicker mockPicker;
    late MockFirebaseStorage mockStorage;
    late MockFirebaseFirestore mockFirestore;
    final String userEmail = 'testuser@example.com';
    final bool isDarkMode = false;

    setUp(() {
      mockPicker = MockImagePicker();
      mockStorage = MockFirebaseStorage();
      mockFirestore = MockFirebaseFirestore();
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

      await tester.tap(find.text('Görsel eklemek için tıklayın'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Tedarik başarıyla paylaşıldı!'), findsOneWidget);
    });
  });
}