import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class UpdateSupply extends StatefulWidget {
  final DocumentSnapshot tedarik;
  final String userEmail;
  final Function toggleTheme;
  final bool isDarkMode;

  UpdateSupply({
    required this.tedarik,
    required this.userEmail,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  UpdateSupplyState createState() => UpdateSupplyState();
}

class UpdateSupplyState extends State<UpdateSupply> {
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tedarik başarıyla güncellendi!'), backgroundColor: Colors.green),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  void _deleteTedarik() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Silme Onayı'),
          content: Text('Bu paylaşımı silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Hayır'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Evet'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('tedarikler')
            .doc(widget.tedarik.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tedarik başarıyla silindi!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
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
          title: Text('Başvuranlar'),
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userEmail: widget.tedarik['basvuranlar'][index],
                          firebaseUser: widget.userEmail,
                          toggleTheme: widget.toggleTheme,
                          isDarkMode: widget.isDarkMode,
                        ),
                      ),
                    );
                  },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tedarik Bilgisi Güncelle',style: TextStyle(color: Colors.white),),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.title, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _baslikController,
                            decoration: InputDecoration(
                              labelText: 'Tedarik Başlığı',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Başlık boş olamaz';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Colors.amber),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _aciklamaController,
                            decoration: InputDecoration(
                              labelText: 'Tedarik Açıklaması',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Açıklama boş olamaz';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on,color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _fiyatController,
                            decoration: InputDecoration(
                              labelText: 'Fiyat (\₺)',
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
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.notes, color: Colors.blueGrey),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _detayliAciklamaController,
                            decoration: InputDecoration(
                              labelText: 'Detaylı Açıklama',
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Detaylı açıklama boş olamaz';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: _updateTedarik,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('Tedarik Güncelle',style: TextStyle(color: Colors.white),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () => _showBasvuranlar(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('Başvuranları Görüntüle',style: TextStyle(color: Colors.white),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: _deleteTedarik,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text(
                      'Paylaşımı Sil',
                      style: TextStyle(color: Colors.white),
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
