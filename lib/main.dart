import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // Giriş ekranı

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase'i başlat
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tedarikçi Uygulaması',
      home: LoginScreen(),
      initialRoute: '/login', // Başlangıç ekranı
      routes: {
        '/login': (context) => LoginScreen(), // Login ekranı
        '/home': (context) => Scaffold(body: Center(child: Text('Ana Ekran'))),
      },
    );
  }
}