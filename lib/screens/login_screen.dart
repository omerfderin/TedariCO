import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  ThemeData _getLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF202124)),
        bodyMedium: TextStyle(color: Color(0xFF3C4043)),
      ),
    );
  }

  ThemeData _getDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Color(0x155E5959),
      scaffoldBackgroundColor: Colors.grey[900],
      cardColor: Colors.grey[800],
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFFAFAFA), fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: Color(0xFFF5F5F5), fontWeight: FontWeight.w400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _getLightTheme(),
      darkTheme: _getDarkTheme(),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: _themeMode == ThemeMode.light ? Colors.white12 : Colors.black45,
          title: Text(
            _isLogin ? 'TedariCO\'ya Giriş Yap' :'TedariCO\'ya Kayıt Ol',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'Hoş Geldiniz' : 'Hesap Oluştur',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]!,
                        ),
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _themeMode == ThemeMode.light ? Colors.blue.withOpacity(0.5) : Colors.grey[400]!.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]!, // Odaklanma rengi buraya ayarlanabilir
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]!,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: _themeMode == ThemeMode.light ? Colors.grey : Colors.grey[400]!,
                    ),
                    SizedBox(height: 13),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]!,
                        ),
                        labelText: 'Şifre',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]!, // Odaklanma rengi buraya ayarlanabilir
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]!,
                          ),
                        ),
                      ),
                      obscureText: true,
                      cursorColor: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]!,
                    ),
                    SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              userEmail: "omer@gmail.com",
                              theme: _themeMode == ThemeMode.light
                                  ? _getLightTheme()
                                  : _getDarkTheme(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.white12, width: 2),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Hesabın yok mu? Kayıt ol'
                            : 'Zaten bir hesabın var mı? Giriş yap',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                            color: _themeMode == ThemeMode.light ? Colors.blue : Colors.grey[400]
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
