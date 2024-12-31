import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'supply_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final String currentUserEmail;
  final Function toggleTheme;
  final bool isDarkMode;

  NotificationsScreen({
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
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Bir hata oluştu\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsScreen(
                            currentUserEmail: currentUserEmail,
                            toggleTheme: toggleTheme,
                            isDarkMode: isDarkMode,
                          ),
                        ),
                      );
                    },
                    child: Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Veriler yüklenemedi'));
          }

          final bildirimler = snapshot.data!.docs;

          if (bildirimler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz bildirim yok',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bildirimler.length,
            itemBuilder: (context, index) {
              try {
                final bildirim = bildirimler[index].data() as Map<String, dynamic>;
                final okundu = bildirim['okundu'] ?? false;
                final bildirimId = bildirimler[index].id;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: okundu ? Colors.grey : Colors.blue,
                      child: Icon(Icons.notifications, color: Colors.white),
                    ),
                    title: Text(bildirim['mesaj'] ?? 'Mesaj yok'),
                    subtitle: Text(
                      'İlan: ${bildirim['tedarikBaslik'] ?? 'Başlık yok'}',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onTap: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('bildirimler')
                            .doc(bildirimId)
                            .update({'okundu': true});

                        final tedarikDoc = await FirebaseFirestore.instance
                            .collection('tedarikler')
                            .doc(bildirim['tedarikId'])
                            .get();

                        if (tedarikDoc.exists) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupplyDetailScreen(
                                tedarik: tedarikDoc,
                                currentUserEmail: currentUserEmail,
                                toggleTheme: toggleTheme,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('İlan bulunamadı veya silinmiş'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('İşlem sırasında bir hata oluştu: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                );
              } catch (e) {
                return SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}
