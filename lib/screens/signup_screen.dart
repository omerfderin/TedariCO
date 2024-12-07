import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Login ekranına yönlendirme

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı kaydını yapma
  void _signUp() async {
    try {
      // Firebase Authentication ile kullanıcı kaydederiz
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("Kullanıcı Kaydedildi: ${userCredential.user?.email}");

      // Kayıt olduktan sonra login ekranına yönlendirme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Hata varsa kullanıcıya mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kayıt Yapılamadı: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-posta"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true, // Şifreyi gizlemek için
              decoration: InputDecoration(labelText: "Şifre"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp, // Kayıt işlemi
              child: Text("Kayıt Ol"),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Login ekranına yönlendirme
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Zaten Hesabınız Var mı? Giriş Yapın"),
            ),
          ],
        ),
      ),
    );
  }
}
