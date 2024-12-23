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
        await FirebaseFirestore.instance.collection('tedarikler').add({
          'baslik': _baslikController.text,
          'aciklama': _aciklamaController.text,
          'fiyat': double.parse(_fiyatController.text),
          'detayli_aciklama': _detayliAciklamaController.text,
          'kullanici': widget.userEmail,
          'basvuranlar': [],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Tedarik başarıyla paylaşıldı!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Mesajın görünmesi için 2 saniye bekleyip sonra yönlendirme yapalım
        await Future.delayed(Duration(seconds: 2));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(
                    userEmail: widget.userEmail, theme: Theme.of(context)),
          ),
              (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Hata: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .primaryColor
                    .withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Yeni Tedarik Oluştur',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme
                          .of(context)
                          .textTheme
                          .displayMedium!
                          .color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInfoField(
                      context: context,
                      controller: _baslikController,
                      label: 'Tedarik Başlığı',
                      icon: Icons.title,
                    ),
                    SizedBox(height: 24),
                    _buildInfoField(
                      context: context,
                      controller: _aciklamaController,
                      label: 'Tedarik Açıklaması',
                      icon: Icons.description,
                    ),
                    SizedBox(height: 24),
                    _buildInfoField(
                      context: context,
                      controller: _fiyatController,
                      label: 'Fiyat (TL)',
                      icon: Icons.monetization_on,
                      iconColor: Colors.green,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 24),
                    _buildInfoField(
                      context: context,
                      controller: _detayliAciklamaController,
                      label: 'Detaylı Açıklama',
                      icon: Icons.article,
                      maxLines: 5,
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveTedarik,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline,
                            color: Colors.green.shade300,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tedarik Paylaş',
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.white10, width: 2),
                        backgroundColor: Theme
                            .of(context)
                            .primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color? iconColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: Theme
          .of(context)
          .colorScheme
          .onSurface,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme
            .of(context)
            .colorScheme
            .onSurface),
        prefixIcon: Icon(icon, color: iconColor ?? Theme
            .of(context)
            .colorScheme
            .onSurface),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme
              .of(context)
              .colorScheme
              .onSurface
              .withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme
                  .of(context)
                  .colorScheme
                  .onSurface,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme
              .of(context)
              .colorScheme
              .onSurface
              .withOpacity(0.3)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label boş olamaz';
        }
        return null;
      },
    );
  }
}