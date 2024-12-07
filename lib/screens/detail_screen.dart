import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TedarikDetayScreen extends StatelessWidget {
  final DocumentSnapshot tedarik;
  final String currentUserEmail;

  TedarikDetayScreen({required this.tedarik, required this.currentUserEmail});

  void _applyToTedarik(BuildContext context) async {
    try {
      // 'basvuranlar' alanını kontrol et ve mevcutsa listeyi al
      List<String> basvuranlar = List<String>.from(tedarik['basvuranlar'] ?? []);

      // Eğer başvurmuşsa, kullanıcıya mesaj göster
      if (basvuranlar.contains(currentUserEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zaten başvurdunuz!')),
        );
        return;
      }

      // Başvuru yapılmadıysa, e-posta adresini ekleyin
      basvuranlar.add(currentUserEmail);

      // Başvuranları Firestore'a kaydedin
      await tedarik.reference.update({
        'basvuranlar': basvuranlar,
      });

      // Bildirim göndermek için Firestore'dan tedarik sahibi bilgisine erişin
      final tedarikSahibiEmail = tedarik['kullanici'];

      // Bildirim göndermek için bir işlem yapılabilir
      await FirebaseFirestore.instance.collection('bildirimler').add({
        'kullanici': tedarikSahibiEmail,
        'basvuran_email': currentUserEmail,
        'mesaj': '$currentUserEmail, başvuruda bulundu!',
        'tarih': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Başvurunuz alındı!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baslik = tedarik['baslik'];
    final aciklama = tedarik['aciklama'];
    final fiyat = tedarik['fiyat'];
    final detayliAciklama = tedarik['detayli_aciklama'];
    final kullanici = tedarik['kullanici'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Tedarik Detayları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Açıklama: $aciklama',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Fiyat: \$${fiyat.toString()}',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              'Detaylı Açıklama: $detayliAciklama',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Paylaşan Kullanıcı: $kullanici',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _applyToTedarik(context),
              child: Text('Başvur'),
            ),
          ],
        ),
      ),
    );
  }
}
