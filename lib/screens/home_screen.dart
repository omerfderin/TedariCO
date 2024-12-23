import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'guncelle.dart';
import 'share_screen.dart';
import 'detail_screen.dart';
import 'paylasimlar.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
   ThemeData theme;

  HomeScreen({required this.userEmail, required this.theme});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String searchQuery = '';
  String sortOption = 'Fiyat: Artan';

  Stream<QuerySnapshot> get _tedariklerStream {
    if (_selectedIndex == 0) {
      return FirebaseFirestore.instance.collection('tedarikler').snapshots();
    } else if (_selectedIndex == 2) {
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

  void _onSortChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        sortOption = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: widget.theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.theme.primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping, size: 30),
              SizedBox(width: 10),
              Text(
                'TedariCO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: _selectedIndex == 1
            ? TedarikEkleScreen(userEmail: widget.userEmail)
            : Column(
          children: [
            if (_selectedIndex == 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tedarik Ara...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onChanged: (query) {
                          setState(() {
                            searchQuery = query;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 300, // Maksimum genişlik
                        maxHeight: 60, // Maksimum yükseklik
                      ),
                      child: DropdownButton<String>(
                        value: sortOption,
                        onChanged: _onSortChanged,
                        items: <String>['Fiyat: Artan', 'Fiyat: Azalan']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                              style: TextStyle(
                                color: widget.theme.colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _tedariklerStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.theme.primaryColor,
                        ),
                      ),
                    );
                  }

                  final tedarikler = snapshot.data!.docs;

                  if (tedarikler.isEmpty && this.runtimeType != KendiPaylasimlarScreen) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 100,
                            color: widget.theme.brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Henüz tedarik bulunmuyor',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'İlk tedariği sen paylaş!',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.theme.brightness == Brightness.dark
                                  ? Colors.grey[500]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (this.runtimeType == KendiPaylasimlarScreen) {
                    return Center(
                      child: Text(
                        'Henüz tedarik paylaşmadınız.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  // Sıralama işlemini burada uygula
                  if (sortOption == 'Fiyat: Artan') {
                    tedarikler.sort((a, b) => (a['fiyat'] as num).compareTo(b['fiyat'] as num));
                  } else if (sortOption == 'Fiyat: Azalan') {
                    tedarikler.sort((a, b) => (b['fiyat'] as num).compareTo(a['fiyat'] as num));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 16),
                    itemCount: tedarikler.length,
                    itemBuilder: (context, index) {
                      final tedarik = tedarikler[index];
                      final baslik = tedarik['baslik'] as String;
                      final aciklama = tedarik['aciklama'] as String;
                      final detayli_aciklama = tedarik['detayli_aciklama'] ?? ''; // Detaylı açıklama
                      final fiyat = tedarik['fiyat'];
                      final kullanici = tedarik['kullanici'] as String;

                      if (searchQuery.isNotEmpty &&
                          !baslik.toLowerCase().contains(searchQuery.toLowerCase())) {
                        return Container();
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                if (_selectedIndex == 2) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GuncelleScreen(tedarik: tedarik),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TedarikDetayScreen(
                                        tedarik: tedarik,
                                        currentUserEmail: widget.userEmail,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                widget.theme.primaryColor,
                                                widget.theme.primaryColor.withOpacity(0.7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.local_shipping,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                baslik,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.onSurface,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                aciklama,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              ),
                                              if (detayli_aciklama.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text(
                                                    detayli_aciklama,
                                                    maxLines: 3, // Maksimum 3 satır göster
                                                    overflow: TextOverflow.ellipsis, // Gerektiğinde '...' ile sonlandır
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '₺${fiyat.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          kullanici,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: widget.theme.primaryColor,
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
        ),
      ),
    );
  }
}