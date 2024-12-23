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

        Navigator.pop(context);
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
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_baslikController, 'Tedarik Başlığı'),
              SizedBox(height: 16),
              _buildTextField(_aciklamaController, 'Tedarik Açıklaması'),
              SizedBox(height: 16),
              _buildTextField(_fiyatController, 'Fiyat', isNumeric: true),
              SizedBox(height: 16),
              _buildTextField(_detayliAciklamaController, 'Detaylı Açıklama', maxLines: 5),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateTedarik,
                child: Text('Tedarik Güncelle'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool isNumeric = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText boş olamaz';
        }
        if (isNumeric && double.tryParse(value) == null) {
          return 'Geçerli bir fiyat girin';
        }
        return null;
      },
      maxLines: maxLines,
    );
  }
}