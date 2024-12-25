import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';

class BildirimlerScreen extends StatelessWidget {
  final String currentUserEmail;
  final Function toggleTheme;
  final bool isDarkMode;

  BildirimlerScreen({
    required this.currentUserEmail,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirimler'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => toggleTheme(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bildirimler')
            .where('alici', isEqualTo: currentUserEmail)
            .orderBy('tarih', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final bildirimler = snapshot.data!.docs;

          if (bildirimler.isEmpty) {
            return Center(child: Text('Henüz bildirim yok'));
          }

          return ListView.builder(
            itemCount: bildirimler.length,
            itemBuilder: (context, index) {
              final bildirim = bildirimler[index];
              final okundu = bildirim['okundu'] ?? false;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: okundu ? Colors.grey : Colors.blue,
                    child: Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(bildirim['mesaj']),
                  subtitle: Text(
                    'İlan: ${bildirim['tedarikBaslik']}',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  onTap: () async {
                    // Bildirimi okundu olarak işaretle
                    await bildirim.reference.update({'okundu': true});

                    // İlgili tedarik dokümanını al
                    final tedarikDoc = await FirebaseFirestore.instance
                        .collection('tedarikler')
                        .doc(bildirim['tedarikId'])
                        .get();

                    if (tedarikDoc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TedarikDetayScreen(
                            tedarik: tedarikDoc,
                            currentUserEmail: currentUserEmail,
                            toggleTheme: toggleTheme,
                            isDarkMode: isDarkMode,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}