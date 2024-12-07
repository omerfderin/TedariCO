import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KendiPaylasimlarScreen extends StatelessWidget {
  final String userEmail;

  KendiPaylasimlarScreen({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kendi Paylaşımlarım'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              final basvuranlar = List<String>.from(tedarik['basvuranlar'] ?? []);
              final basvuranlarString = basvuranlar.join(', ');

              return ListTile(
                title: Text(tedarik['baslik']),
                subtitle: Text('Başvuranlar: $basvuranlarString'),
              );
            },
          );
        },
      ),
    );
  }
}
