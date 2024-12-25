import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'guncelle.dart';

class KendiPaylasimlarScreen extends StatelessWidget {
  final String userEmail;
  final Function toggleTheme;
  final bool isDarkMode;

  KendiPaylasimlarScreen({
    required this.userEmail,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tedarikler')
            .where('kullanici', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tedarikler = snapshot.data!.docs;

          if (tedarikler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz paylaşım yapmadınız',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tedarikler.length,
            itemBuilder: (context, index) {
              final tedarik = tedarikler[index];
              final baslik = tedarik['baslik'];
              final aciklama = tedarik['aciklama'];
              final fiyat = tedarik['fiyat'];
              final imageUrl = tedarik['imageUrl'];
              final sektor = tedarik['sektor'] ?? 'Sektör bilgisi yok';
              final basvuranlar = List<String>.from(tedarik['basvuranlar'] ?? []);

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuncelleScreen(
                          tedarik: tedarik,
                          userEmail: userEmail,
                          toggleTheme: toggleTheme,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                baslik,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Theme.of(context).textTheme.headlineLarge?.color,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.monetization_on,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${fiyat.toString()}\₺',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.business, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sektör: $sektor',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.description, color: Colors.amber),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Açıklama: $aciklama',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.people, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Başvuranlar: ${basvuranlar.length}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        if (imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}