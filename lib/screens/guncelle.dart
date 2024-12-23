import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tedarikci_uygulamasi/screens/profile_screen.dart';
import 'paylasimlar.dart';

class GuncelleScreen extends StatefulWidget {
  final DocumentSnapshot tedarik;

  GuncelleScreen({required this.tedarik});

  @override
  _GuncelleScreenState createState() => _GuncelleScreenState();
}

class _GuncelleScreenState extends State<GuncelleScreen> {
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
        await FirebaseFirestore.instance
            .collection('tedarikler')
            .doc(widget.tedarik.id)
            .update({
          'baslik': _baslikController.text,
          'aciklama': _aciklamaController.text,
          'fiyat': double.parse(_fiyatController.text),
          'detayli_aciklama': _detayliAciklamaController.text,
        });

        // Başarılı güncelleme mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Tedarik başarıyla güncellendi!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, 'Tedarik başarıyla güncellendi!');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showBasvuranlar(BuildContext context) {
    final basvuranlar = List<String>.from(widget.tedarik['basvuranlar'] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Başvuranlar',style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor.withOpacity(0.8))),
          content: basvuranlar.isEmpty
              ? Text('Henüz başvuru yok.')
              : SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: basvuranlar.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(basvuranlar[index]),
                  onTap: () => _navigateToProfile(basvuranlar[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToProfile(String kullaniciEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userEmail: kullaniciEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Tedarik Güncelle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tedarik Bilgilerini Düzenle',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface
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
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      context: context,
                      controller: _baslikController,
                      label: 'Tedarik Başlığı',
                      icon: Icons.title,
                    ),
                    SizedBox(height: 24),
                    _buildInfoField(
                      iconColor: Theme.of(context).colorScheme.onSurface,
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
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      context: context,
                      controller: _detayliAciklamaController,
                      label: 'Detaylı Açıklama',
                      icon: Icons.article,
                      maxLines: 5,
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _updateTedarik,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tedariği Güncelle',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.white10, width: 2),
                        backgroundColor: Theme.of(context).cardColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showBasvuranlar(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Başvuranları Görüntüle',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.white10, width: 2),
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
    int? maxLines,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            cursorColor: Theme.of(context).colorScheme.onSurface,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface, // Odaklanma rengi buraya ayarlanabilir
                ),
              ),
              prefixIcon: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.onSurface),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
              ),
            ),

            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label boş olamaz';
              }
              if (keyboardType == TextInputType.number && double.tryParse(value) == null) {
                return 'Geçerli bir sayı girin';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}