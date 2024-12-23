import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // Giriş ekranı
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase'i başlat
  runApp(MyApp());
}

@override
void initState() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Bildirim geldi: ${message.notification?.title}');
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tedarikçi Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Başlangıç ekranı
      routes: {
        '/login': (context) => LoginScreen(), // Login ekranı
        '/home': (context) => Scaffold(body: Center(child: Text('Ana Ekran'))),
      },
    );
  }
}
