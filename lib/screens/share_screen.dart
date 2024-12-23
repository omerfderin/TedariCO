import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home_screen.dart'; // Ana ekranı import et

class TedarikEkleScreen extends StatefulWidget {
  final String userEmail;

  TedarikEkleScreen({required this.userEmail});

  @override
  _TedarikEkleScreenState createState() => _TedarikEkleScreenState();
}

class _TedarikEkleScreenState extends State<TedarikEkleScreen> {
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _fiyatController = TextEditingController();
  final _detayliAciklamaController = TextEditingController();
  XFile? _image; // Görsel değişkeni

  final _picker = ImagePicker();

  String? _selectedSector; // Seçilen sektör

  // Sektör listesini tanımlıyoruz
  final List<String> _sectors = [
    'Teknoloji',
    'Tarım',
    'Sanayi',
    'Sağlık',
    'Eğitim',
    'Gıda',
    'Perakende'
  ];

  // Görsel seçme
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  // Tedarik paylaşma
  Future<void> _shareTedarik() async {
    if (_image != null && _selectedSector != null) {
      try {
        // Firebase Storage'a görsel yükle
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('tedarik_resimleri')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(File(_image!.path));

        // Görselin URL'sini al
        final imageUrl = await storageRef.getDownloadURL();

        // Firestore'a tedarik kaydet
        await FirebaseFirestore.instance.collection('tedarikler').add({
          'baslik': _baslikController.text,
          'aciklama': _aciklamaController.text,
          'fiyat': double.tryParse(_fiyatController.text) ?? 0,
          'detayli_aciklama': _detayliAciklamaController.text,
          'kullanici': widget.userEmail,
          'imageUrl': imageUrl, // Görsel URL'si
          'basvuranlar': [],
          'sektor': _selectedSector, // Seçilen sektör
        });

        // Başarılı işlem sonrası ana ekrana yönlendirme
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tedarik başarıyla paylaşıldı!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userEmail: widget.userEmail)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lütfen bir görsel ve sektör seçin!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
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
                color: Colors.blue[50],
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
                            border: InputBorder.none,
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
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: Colors.green, size: 30),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _aciklamaController,
                          decoration: InputDecoration(
                            labelText: 'Tedarik Açıklaması',
                            border: InputBorder.none,
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
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.orange, size: 30),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _fiyatController,
                          decoration: InputDecoration(
                            labelText: 'Fiyat',
                            border: InputBorder.none,
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
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.details, color: Colors.purple, size: 30),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _detayliAciklamaController,
                          decoration: InputDecoration(
                            labelText: 'Detaylı Açıklama',
                            border: InputBorder.none,
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
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.business, color: Colors.teal, size: 30),
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
                  color: Colors.teal[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.teal, size: 30),
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
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.photo, color: Colors.teal, size: 30),
                      SizedBox(width: 16),
                      TextButton(
                        onPressed: _pickImage,
                        child: Text('Görsel Seç', style: TextStyle(color: Colors.teal, fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
              if (_image != null) ...[
                SizedBox(height: 16),
                Image.file(File(_image!.path), height: 200, fit: BoxFit.cover),
              ],
              SizedBox(height: 20),

              // Paylaş Butonu
              ElevatedButton(
                onPressed: _shareTedarik,
                child: Text('Tedarik Paylaş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Buton rengi
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
    );
  }
}
