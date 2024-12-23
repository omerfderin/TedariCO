import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'guncelle.dart';

class KendiPaylasimlarScreen extends StatelessWidget {
  final String userEmail;

  KendiPaylasimlarScreen({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kendi Paylaşımlarım'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Yeni Tedarik Oluştur',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
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

                return ListView.builder(
                  itemCount: tedarikler.length,
                  itemBuilder: (context, index) {
                    final tedarik = tedarikler[index];
                    final basvuranlar =
                    List<String>.from(tedarik['basvuranlar'] ?? []);
                    final basvuranlarString = basvuranlar.join(', ');

                    return ListTile(
                      title: Text(tedarik['baslik']),
                      subtitle: Text('Başvuranlar: $basvuranlarString'),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GuncelleScreen(tedarik: tedarik),
                          ),
                        );

                        if (result != null && result is String) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}