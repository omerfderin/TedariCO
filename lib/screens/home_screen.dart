import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/Ba%C5%9Fvurular%C4%B1m.dart';
import 'package:tedarikci_uygulamasi/screens/paylasimlar.dart';
import 'guncelle.dart';
import 'share_screen.dart';
import 'detail_screen.dart';
import 'bildirimler.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final Function toggleTheme;
  final bool isDarkMode;

  HomeScreen({
    required this.userEmail,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String searchQuery = '';
  String _selectedFilter = 'Fiyat (Azdan Çoğa)';

  Stream<QuerySnapshot> get _tedariklerStream {
    Query query = FirebaseFirestore.instance.collection('tedarikler');

    if (_selectedIndex == 0) {
      if (_selectedFilter == 'Fiyat (Azdan Çoğa)') {
        query = query.orderBy('fiyat', descending: false);
      } else if (_selectedFilter == 'Fiyat (Çoktan Aza)') {
        query = query.orderBy('fiyat', descending: true);
      }
    } else if (_selectedIndex == 2) {
      query = query.where('kullanici', isEqualTo: widget.userEmail);
    }

    return query.snapshots();
  }

  void _onItemTapped(int index) {
    setState(() {
      searchQuery = '';
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _selectedIndex == 0
              ? 'Ana Akış'
              : _selectedIndex == 1
              ? 'Tedarik Ekle'
              : 'Paylaşımlarım',
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bildirimler')
                .where('alici', isEqualTo: widget.userEmail)
                .where('okundu', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int bildirimSayisi = snapshot.hasData ? snapshot.data!.docs.length : 0;

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_rounded),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BildirimlerScreen(
                            currentUserEmail: widget.userEmail,
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                          ),
                        ),
                      );
                    },
                  ),
                  if (bildirimSayisi > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$bildirimSayisi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).cardColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _selectedIndex == 3
            ? BasvurularimScreen(
          userEmail: widget.userEmail,
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        )
            : _selectedIndex == 1
            ? TedarikEkleScreen(
          userEmail: widget.userEmail,
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        )
            : _selectedIndex == 2
            ? KendiPaylasimlarScreen(
          userEmail: widget.userEmail,
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        )
            : Column(
          children: [
            if (_selectedIndex == 0)
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
                          prefixIcon: Icon(Icons.search),
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
                      icon: Icon(Icons.filter_list),
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
                      final imageUrl = tedarik['imageUrl'];
                      final sektor = tedarik['sektor'] ?? 'Sektör bilgisi yok';

                      if (searchQuery.isNotEmpty &&
                          !baslik.toLowerCase().contains(searchQuery.toLowerCase())) {
                        return Container();
                      }

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 10,
                        child: InkWell(
                          onTap: () {
                            searchQuery = '';
                            if (_selectedIndex == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GuncelleScreen(
                                    tedarik: tedarik,
                                    userEmail: widget.userEmail,
                                    toggleTheme: widget.toggleTheme,
                                    isDarkMode: widget.isDarkMode,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TedarikDetayScreen(
                                    tedarik: tedarik,
                                    currentUserEmail: widget.userEmail,
                                    toggleTheme: widget.toggleTheme,
                                    isDarkMode: widget.isDarkMode,
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
                                    Icon(Icons.account_circle, color: Colors.blue),
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
      ),
      bottomNavigationBar: ClipRRect(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
            BottomNavigationBarItem(                    // Yeni eklenen item
              icon: Icon(Icons.assignment_turned_in),
              label: 'Başvurularım',
            ),
          ],
        ),
      ),
    );
  }
}