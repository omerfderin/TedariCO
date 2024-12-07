import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'guncelle.dart';
import 'share_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;

  HomeScreen({required this.userEmail});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Sekme durumu (0 = Ana Akış, 1 = Tedarik Ekle, 2 = Kendi Paylaşımlarım)
  String searchQuery = '';

  Stream<QuerySnapshot> get _tedariklerStream {
    if (_selectedIndex == 0) {
      // Ana akış: Tüm tedarikler
      return FirebaseFirestore.instance.collection('tedarikler').snapshots();
    } else if (_selectedIndex == 2) {
      // Kendi paylaşımlarım: Kullanıcının paylaştığı tedarikler
      return FirebaseFirestore.instance
          .collection('tedarikler')
          .where('kullanici', isEqualTo: widget.userEmail)
          .snapshots();
    }
    return const Stream.empty();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Ekran'),
      ),
      body: _selectedIndex == 1
          ? TedarikEkleScreen(userEmail: widget.userEmail) // Tedarik ekleme ekranı
          : Column(
        children: [
          if (_selectedIndex == 0) // Sadece Ana Akışta arama çubuğu göster
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Tedarik Ara...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _tedariklerStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final tedarikler = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: tedarikler.length,
                  itemBuilder: (context, index) {
                    final tedarik = tedarikler[index];
                    final baslik = tedarik['baslik'];
                    final aciklama = tedarik['aciklama'];
                    final fiyat = tedarik['fiyat'];
                    final kullanici = tedarik['kullanici'];

                    // Arama sorgusunu filtrele
                    if (searchQuery.isNotEmpty &&
                        !baslik.toLowerCase().contains(searchQuery.toLowerCase())) {
                      return Container(); // Uyumayan kartı göstermeyin
                    }

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          baslik,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          'Açıklama: $aciklama\nFiyat: \$${fiyat.toString()}\nKullanıcı: $kullanici',
                          style: TextStyle(fontSize: 16),
                        ),
                        isThreeLine: true,
                        onTap: () {
                          if (_selectedIndex == 2) {
                            // Kendi paylaşımlarında güncelleme ekranına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GuncelleScreen(tedarik: tedarik),
                              ),
                            );
                          } else {
                            // Diğer akışlarda detay ekranına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TedarikDetayScreen(
                                  tedarik: tedarik, // Firestore'dan gelen tedarik verisi
                                  currentUserEmail: widget.userEmail, // Kullanıcı e-posta bilgisi
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Akış',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Tedarik Ekle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Kendi Paylaşımlarım',
          ),
        ],
      ),
    );
  }
}
