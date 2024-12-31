import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class SupplyDetailScreen extends StatefulWidget {
  final DocumentSnapshot tedarik;
  final String currentUserEmail;
  final Function toggleTheme;
  final bool isDarkMode;

  SupplyDetailScreen({
    required this.tedarik,
    required this.currentUserEmail,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  SupplyDetailScreenState createState() => SupplyDetailScreenState();

  _toggleApplication() {}
}

class SupplyDetailScreenState extends State<SupplyDetailScreen> {
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  void _checkIfApplied() {
    List<dynamic> basvuranlar = widget.tedarik['basvuranlar'] ?? [];
    setState(() {
      _hasApplied = basvuranlar.contains(widget.currentUserEmail);
    });
  }

  void _toggleApplication() async {
    try {
      List<dynamic> basvuranlar = List.from(widget.tedarik['basvuranlar'] ?? []);

      if (_hasApplied) {
        basvuranlar.remove(widget.currentUserEmail);
      } else {
        basvuranlar.add(widget.currentUserEmail);

        // Bildirim oluştur
        await FirebaseFirestore.instance.collection('bildirimler').add({
          'alici': widget.tedarik['kullanici'],
          'gonderen': widget.currentUserEmail,
          'tedarikId': widget.tedarik.id,
          'tedarikBaslik': widget.tedarik['baslik'],
          'mesaj': '${widget.currentUserEmail} ilanınıza başvurdu',
          'okundu': false,
          'tarih': FieldValue.serverTimestamp(),
          'tip': 'basvuru'
        });
      }

      await FirebaseFirestore.instance
          .collection('tedarikler')
          .doc(widget.tedarik.id)
          .update({'basvuranlar': basvuranlar});

      setState(() {
        _hasApplied = !_hasApplied;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_hasApplied ? 'Başvuru yapıldı!' : 'Başvuru geri çekildi.'),
          backgroundColor: _hasApplied ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.network(
              imageUrl,
              fit: BoxFit.fitWidth,
              height: MediaQuery.of(context).size.height * 0.8,
            ),
          ),
        );
      },
    );
  }

  void _navigateToUserProfile(String userEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userEmail: userEmail,
          firebaseUser: widget.currentUserEmail,
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baslik = widget.tedarik['baslik'];
    final aciklama = widget.tedarik['aciklama'];
    final fiyat = widget.tedarik['fiyat'];
    final detayliAciklama = widget.tedarik['detayli_aciklama'];
    final kullanici = widget.tedarik['kullanici'];
    final imageUrl = widget.tedarik['imageUrl'] ?? '';
    final sektor = widget.tedarik['sektor'] ?? 'Sektör bilgisi mevcut değil';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tedarik Detayları',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
        centerTitle: true,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 16),

                GestureDetector(
                  onTap: () => _navigateToUserProfile(kullanici),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                              )
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.blueAccent),
                              SizedBox(width: 8),
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
                            Icon(Icons.description, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(
                              'Açıklama:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          aciklama,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

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
                          'Fiyat: ${fiyat.toString()}\₺',
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
                    child: Row(
                      children: [
                        Icon(Icons.business, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Sektör: $sektor',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
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
                            Icon(Icons.notes, color: Colors.blueGrey),
                            SizedBox(width: 8),
                            Text(
                              'Detaylı Açıklama:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          detayliAciklama,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),

                if (widget.tedarik['kullanici'] != widget.currentUserEmail)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _toggleApplication,
                      icon: Icon(
                        _hasApplied ? Icons.close : Icons.check_circle,
                        color: Colors.white,
                      ),
                      label: Text(
                        _hasApplied ? 'Başvuruyu Geri Çek' : 'Başvur',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasApplied ? Colors.red : Theme.of(context).primaryColor,
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
      ),
    );
  }
}