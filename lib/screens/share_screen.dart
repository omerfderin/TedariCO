import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home_screen.dart';

class ShareScreen extends StatefulWidget {
  final String userEmail;
  final Function toggleTheme;
  final bool isDarkMode;

  ShareScreen({
    required this.userEmail,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  ShareScreenState createState() => ShareScreenState();
}

class ShareScreenState extends State<ShareScreen> {
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _fiyatController = TextEditingController();
  final _detayliAciklamaController = TextEditingController();
  XFile? _image;
  final _picker = ImagePicker();
  String? _selectedSector;

  final List<String> _sectors = [
    'Teknoloji',
    'Tarım',
    'Sanayi',
    'Sağlık',
    'Eğitim',
    'Gıda',
    'Perakende'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _shareTedarik() async {
    if (_baslikController.text.isEmpty ||
        _aciklamaController.text.isEmpty ||
        _fiyatController.text.isEmpty ||
        _detayliAciklamaController.text.isEmpty ||
        _image == null ||
        _selectedSector == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun ve bir görsel seçin!')),
      );
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('tedarik_resimleri')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(File(_image!.path));

      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('tedarikler').add({
        'baslik': _baslikController.text,
        'aciklama': _aciklamaController.text,
        'fiyat': double.tryParse(_fiyatController.text) ?? 0,
        'detayli_aciklama': _detayliAciklamaController.text,
        'kullanici': widget.userEmail,
        'imageUrl': imageUrl,
        'basvuranlar': [],
        'sektor': _selectedSector,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tedarik başarıyla paylaşıldı!'), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userEmail: widget.userEmail,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget yapısı aynı kalacak, sadece tema ile ilgili güncellemeler yapılacak
    return Scaffold(
      appBar: null, // HomeScreen içinde olduğu için AppBar'a gerek yok
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
              children: [
                // Başlık Kartı
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.title, color: Colors.blue, size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _baslikController,
                            decoration: InputDecoration(
                              labelText: 'Tedarik Başlığı',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Açıklama Kartı
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Colors.amber, size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _aciklamaController,
                            decoration: InputDecoration(
                              labelText: 'Tedarik Açıklaması',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Fiyat Kartı
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.green, size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _fiyatController,
                            decoration: InputDecoration(
                              labelText: 'Fiyat (\₺)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Detaylı Açıklama Kartı
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.notes, color: Colors.blueGrey, size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _detayliAciklamaController,
                            decoration: InputDecoration(
                              labelText: 'Detaylı Açıklama',
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Sektör Seçim Kartı
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.business, color: Colors.green, size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedSector,
                            hint: Text('Sektör Seçin'),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSector = newValue;
                              });
                            },
                            items: _sectors.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Sektör Detay Kartı (Seçilen sektör burada gösterilecek)
                if (_selectedSector != null) ...[
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: Colors.green, size: 30),
                          SizedBox(width: 16),
                          Text(
                            'Seçilen Sektör: $_selectedSector',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Görsel Seçme Kartı
                // Görsel Seçme Kartı
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo, color: Colors.blueAccent, size: 30),
                        SizedBox(width: 16),
                        TextButton(
                          onPressed: _pickImage,
                          child: Text(
                            'Görsel eklemek için tıklayın',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_image != null) ...[
                  SizedBox(height: 16),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15), // Köşeleri yuvarla
                        child: Image.file(
                          File(_image!.path),
                          height: 200,
                          fit: BoxFit.cover,
                          width: double.infinity, // Kartın tamamını kapla
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 20),



                // Paylaş Butonu
                ElevatedButton(
                  onPressed: _shareTedarik,
                  child: Text('Tedarik Paylaş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                  style: ElevatedButton.styleFrom(// Buton rengi
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
