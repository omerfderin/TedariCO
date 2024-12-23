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
  int _selectedIndex = 0; // Sekme durumu
  String searchQuery = '';
  String _selectedFilter = 'Fiyat (Azdan Çoğa)'; // Varsayılan filtre

  Stream<QuerySnapshot> get _tedariklerStream {
    Query query = FirebaseFirestore.instance.collection('tedarikler');

    if (_selectedIndex == 0) {
      // Ana akış: Tüm tedarikler
      if (_selectedFilter == 'Fiyat (Azdan Çoğa)') {
        query = query.orderBy('fiyat', descending: false); // Azdan çoğa
      } else if (_selectedFilter == 'Fiyat (Çoktan Aza)') {
        query = query.orderBy('fiyat', descending: true); // Çoktan aza
      }
    } else if (_selectedIndex == 2) {
      // Kendi paylaşımlarım: Kullanıcının paylaştığı tedarikler
      query = query.where('kullanici', isEqualTo: widget.userEmail);
    }

    return query.snapshots();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Ana Akış'
              : _selectedIndex == 1
              ? 'Tedarik Ekle'
              : 'Kendi Paylaşımlarım',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _selectedIndex == 1
          ? TedarikEkleScreen(userEmail: widget.userEmail) // Tedarik ekleme
          : Column(
        children: [
          if (_selectedIndex == 0) // Ana akışta arama çubuğu ve filtreleme
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Tedarik Ara...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon:
                        Icon(Icons.search, color: Colors.deepPurple),
                      ),
                      onChanged: (query) {
                        setState(() {
                          searchQuery = query;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    icon: Icon(Icons.filter_list, color: Colors.deepPurple),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                    items: <String>[
                      'Fiyat (Azdan Çoğa)',
                      'Fiyat (Çoktan Aza)',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
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
                    final imageUrl = tedarik['imageUrl']; // Görsel URL'si
                    final sektor =
                        tedarik['sektor'] ?? 'Sektör bilgisi yok'; // Sektör bilgisi

                    // Arama sorgusunu filtrele
                    if (searchQuery.isNotEmpty &&
                        !baslik
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase())) {
                      return Container(); // Uyumayan kartı göstermeyin
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 10,
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          if (_selectedIndex == 2) {
                            // Kendi paylaşımlarında güncelleme ekranına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GuncelleScreen(tedarik: tedarik),
                              ),
                            );
                          } else {
                            // Diğer akışlarda detay ekranına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TedarikDetayScreen(
                                  tedarik:
                                  tedarik, // Firestore'dan gelen tedarik verisi
                                  currentUserEmail: widget.userEmail,
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Başlık ve fiyat kısmı
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      baslik,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.deepPurple,
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
                                    '${fiyat.toString()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Açıklama kısmı
                              Row(
                                children: [
                                  Icon(Icons.description_outlined,
                                      color: Colors.grey[700]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      aciklama,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700]),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Sektör kısmı
                              Row(
                                children: [
                                  Icon(Icons.business_center,
                                      color: Colors.deepPurple),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Sektör: $sektor',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Kullanıcı kısmı
                              Row(
                                children: [
                                  Icon(Icons.account_circle,
                                      color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    kullanici,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Görsel kısmı
                              if (imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
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
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Ana Akış',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded),
              label: 'Tedarik Ekle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
              label: 'Paylaşımlarım',
            ),
          ],
        ),
      ),
    );
  }
}
