import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

@override
void initState() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Bildirim geldi: ${message.notification?.title}');
  });
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _currentThemeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _currentThemeMode = _currentThemeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tedarikçi Uygulaması',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF4285F4, {
          50: Color(0xFFE8F0FE),
          100: Color(0xFFD2E3FC),
          200: Color(0xFFBAD1FA),
          300: Color(0xFFA1BEF8),
          400: Color(0xFF89ABF6),
          500: Color(0xFF4285F4),
          600: Color(0xFF3A78E0),
          700: Color(0xFF326ACB),
          800: Color(0xFF295DB7),
          900: Color(0xFF1E4AA0),
        }),
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.light(
          secondaryContainer: Colors.blueAccent,
          primary: Color(0xFF4285F4),
          secondary: Color(0xFF7288A6),
          onSecondary: Color(0xFFFDFDFD),
          surface: Color(0xFFFFFFFF),
        ),
        cardColor: Colors.blue[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.black87,
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
          bodySmall:  TextStyle(fontSize: 14, color: Colors.black54),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        dividerColor: Colors.blueGrey[100],
        buttonTheme: ButtonThemeData(
            buttonColor:  Colors.blueAccent
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(
          selectedColor:  Colors.blueAccent,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: MaterialColor(0xFF303134, {
          50: Color(0xFF303134),
          100: Color(0xFF28292A),
          200: Color(0xFF242526),
          300: Color(0xFF202122),
          400: Color(0xFF1C1D1E),
          500: Color(0xFF18191A),
          600: Color(0xFF151617),
          700: Color(0xFF121314),
          800: Color(0xFF0F1011),
          900: Color(0xFF0B0C0D),
        }),
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.dark(
          secondaryContainer: Color(0xFF494A54),
          primary: Color(0xFF8AB4F8),
          secondary: Color(0xFF5F6368),
          onSecondary: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
        ),
        cardColor: Colors.grey[800],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
          bodySmall: TextStyle(fontSize: 14, color: Colors.white54),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        dividerColor: Colors.grey[700],
        buttonTheme: ButtonThemeData(
          buttonColor:  Colors.grey,
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(
          selectedColor:  Colors.grey[700],
        ),
      ),
      themeMode: _currentThemeMode,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => LoginScreen(
              toggleTheme: toggleTheme,
              isDarkMode: _currentThemeMode == ThemeMode.system,
            ),
          );
        } else if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(
              userEmail: args['userEmail'] ?? '',
              toggleTheme: toggleTheme,
              isDarkMode: _currentThemeMode == ThemeMode.dark,
            ),
          );
        }
        return null;
      },
    );
  }
}
