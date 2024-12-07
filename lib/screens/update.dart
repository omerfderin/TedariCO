import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TedarikUpdateScreen extends StatefulWidget {
  final DocumentSnapshot tedarik;

  TedarikUpdateScreen({required this.tedarik});

  @override
  _TedarikUpdateScreenState createState() => _TedarikUpdateScreenState();
}

class _TedarikUpdateScreenState extends State<TedarikUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _fiyatController = TextEditingController();
  final _detayliAciklamaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mevcut tedarik verilerini controller'lara atıyoruz
    _baslikController.text = widget.tedarik['baslik'];
    _aciklamaController.text = widget.tedarik['aciklama'];
    _fiyatController.text = widget.tedarik['fiyat'].toString();
    _detayliAciklamaController.text = widget.tedarik['detayli_aciklama'];
  }

  void _updateTedarik() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('tedarikler').doc(widget.tedarik.id).update({
          'baslik': _baslikController.text,
          'aciklama': _aciklamaController.text,
          'fiyat': double.parse(_fiyatController.text),
          'detayli_aciklama': _detayliAciklamaController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tedarik başarıyla güncellendi!')),
        );

        Navigator.pop(context); // Güncelleme sonrası geri dön
      } catch (e) {
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
        title: Text('Tedarik Güncelle'),
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
                  labelText: 'Detaylı Açıklama (Gizli)',
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
                onPressed: _updateTedarik,
                child: Text('Tedarik Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
