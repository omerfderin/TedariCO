import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TedarikDetayScreen extends StatelessWidget {
  final DocumentSnapshot tedarik;
  final String currentUserEmail;

  TedarikDetayScreen({required this.tedarik, required this.currentUserEmail});

  void _applyToTedarik(BuildContext context) async {
    try {
      List<String> basvuranlar = List<String>.from(tedarik['basvuranlar'] ?? []);

      if (basvuranlar.contains(currentUserEmail)) {
        _showErrorDialog(context);
        return;
      }

      basvuranlar.add(currentUserEmail);

      await tedarik.reference.update({
        'basvuranlar': basvuranlar,
      });

      final tedarikSahibiEmail = tedarik['kullanici'];

      await FirebaseFirestore.instance.collection('bildirimler').add({
        'kullanici': tedarikSahibiEmail,
        'basvuran_email': currentUserEmail,
        'mesaj': '$currentUserEmail, başvuruda bulundu!',
        'tarih': Timestamp.now(),
      });

      _showSuccessDialog(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height * 0.8,
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Başvuru Başarılı!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Başvurunuz başarıyla alındı. İlgili kullanıcı size geri dönüş yapacaktır.',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Tamam',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Başvuru Hatası!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bu tedariğe zaten başvurdunuz!',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Tamam',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baslik = tedarik['baslik'];
    final aciklama = tedarik['aciklama'];
    final fiyat = tedarik['fiyat'];
    final detayliAciklama = tedarik['detayli_aciklama'];
    final kullanici = tedarik['kullanici'];
    final imageUrl = tedarik['imageUrl'] ?? '';
    final sektor = tedarik['sektor'] ?? 'Sektör bilgisi mevcut değil';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tedarik Detayları',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baslik,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.teal,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 16),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Açıklama:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        aciklama,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Sektör Kartı
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.business_center, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        'Sektör: $sektor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Fiyat: \$${fiyat.toString()}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description_outlined, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Detaylı Açıklama:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        detayliAciklama,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text(
                            'Paylaşan Kullanıcı:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        kullanici,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              if (imageUrl.isNotEmpty)
                GestureDetector(
                  onTap: () => _showFullScreenImage(context, imageUrl),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 30),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _applyToTedarik(context),
                  icon: Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    'Başvur',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
