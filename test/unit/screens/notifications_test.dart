import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Bildirim Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('markAsRead', () async {
      final notification = await fakeFirestore.collection('bildirimler').add({
        'alici': 'test@mail.com',
        'mesaj': 'Test bildirimi',
        'okundu': false,
      });

      final doc = await notification.get();
      expect(doc.get('okundu'), false);

      await notification.update({'okundu': true});
      final updatedDoc = await notification.get();
      expect(updatedDoc.get('okundu'), true);
    });

    test('filterNotifications', () async {
      await fakeFirestore.collection('bildirimler').add({
        'alici': 'test@mail.com',
        'mesaj': 'First notification',
        'okundu': false,
      });

      await fakeFirestore.collection('bildirimler').add({
        'alici': 'other@mail.com',
        'mesaj': 'Second notification',
        'okundu': false,
      });

      final result = await fakeFirestore
          .collection('bildirimler')
          .where('alici', isEqualTo: 'test@mail.com')
          .get();

      expect(result.docs.length, 1);
      expect(result.docs.first.get('mesaj'), 'First notification');
    });
  });
}