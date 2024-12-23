import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarikci_uygulamasi/screens/profile_screen.dart';

class TedarikDetayScreen extends StatefulWidget {
  final DocumentSnapshot tedarik;
  final String currentUserEmail;

  TedarikDetayScreen({required this.tedarik, required this.currentUserEmail});

  @override
  _TedarikDetayScreenState createState() => _TedarikDetayScreenState();
}

class _TedarikDetayScreenState extends State<TedarikDetayScreen> {
  void _applyToTedarik() async {
    try {
      List<String> basvuranlar = List<String>.from(
          widget.tedarik['basvuranlar'] ?? []);

      if (widget.tedarik['kullanici'] == widget.currentUserEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kendi tedariğinize başvuramazsınız!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (basvuranlar.contains(widget.currentUserEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Zaten başvurdunuz!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      basvuranlar.add(widget.currentUserEmail);
      await widget.tedarik.reference.update({'basvuranlar': basvuranlar});
      final tedarikSahibiEmail = widget.tedarik['kullanici'];

      await FirebaseFirestore.instance.collection('bildirimler').add({
        'kullanici': tedarikSahibiEmail,
        'basvuran_email': widget.currentUserEmail,
        'mesaj': '${widget.currentUserEmail}, başvuruda bulundu!',
        'tarih': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Başvurunuz başarıyla alındı!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  void _navigateToProfile(String kullaniciEmail) {
    setState(() {});
    Future.delayed(Duration(milliseconds: 200), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userEmail: kullaniciEmail),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final baslik = widget.tedarik['baslik'];
    final aciklama = widget.tedarik['aciklama'];
    final fiyat = widget.tedarik['fiyat'];
    final detayliAciklama = widget.tedarik['detayli_aciklama'];
    final kullanici = widget.tedarik['kullanici'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        title: Text(
          'Tedarik Detayları',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () => _navigateToProfile(kullanici),
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text(
                          'Paylaşan: $kullanici',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            height: 3,
                            decorationColor: Colors.grey[400],
                            decorationThickness: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    context,
                    'Fiyat',
                    '₺${fiyat.toStringAsFixed(2)}',
                    Icons.monetization_on,
                    Colors.green,
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection(
                    context,
                    'Açıklama',
                    aciklama,
                    Icons.description,
                    Theme
                        .of(context)
                        .colorScheme
                        .onSurface,
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection(
                    context,
                    'Detaylı Açıklama',
                    detayliAciklama,
                    Icons.article,
                    Theme
                        .of(context)
                        .colorScheme
                        .onSurface,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _applyToTedarik,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green.shade300),
                        SizedBox(width: 8),
                        Text(
                          'Başvur',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context,
      String title,
      String content,
      IconData icon,
      Color iconColor,) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .cardColor,
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
              Icon(icon, color: iconColor),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Theme
                  .of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}