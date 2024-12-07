import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class TedarikEkleScreen extends StatefulWidget {
  final String userEmail;

  TedarikEkleScreen({required this.userEmail});

  @override
  _TedarikEkleScreenState createState() => _TedarikEkleScreenState();
}

class _TedarikEkleScreenState extends State<TedarikEkleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _fiyatController = TextEditingController();
  final _detayliAciklamaController = TextEditingController();

  Future<void> _saveTedarik() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Firestore veritabanına tedarik ekleme
        await FirebaseFirestore.instance.collection('tedarikler').add({
          'baslik': _baslikController.text,
          'aciklama': _aciklamaController.text,
          'fiyat': double.parse(_fiyatController.text),
          'detayli_aciklama': _detayliAciklamaController.text,
          'kullanici': widget.userEmail, // Kullanıcı e-posta bilgisi
          'basvuranlar': [], // Başvuranlar listesi başlangıçta boş
        });

        // Başarılı bir şekilde tedarik eklendiğinde, mesaj göster ve HomeScreen'e yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tedarik başarıyla eklendi!')),
        );

        // Ana ekrana dön ve önceki stack'leri temizle
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userEmail: widget.userEmail), // Burada widget.userEmail'i doğru geçiyoruz
          ),
              (route) => false,
        );
      } catch (e) {
        // Hata durumunda bir uyarı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tedarik Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _baslikController,
                decoration: InputDecoration(
                  labelText: 'Tedarik Başlığı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _aciklamaController,
                decoration: InputDecoration(
                  labelText: 'Tedarik Açıklaması',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _fiyatController,
                decoration: InputDecoration(
                  labelText: 'Fiyat',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Fiyat boş olamaz';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir fiyat girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _detayliAciklamaController,
                decoration: InputDecoration(
                  labelText: 'Detaylı Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Detaylı açıklama boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveTedarik,
                child: Text('Tedarik Paylaş'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
