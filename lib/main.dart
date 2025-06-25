import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'pages/login_pages.dart';
import 'pages/home_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Litera',
      theme: ThemeData(
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xfff8c9d3),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xfff8c9d3), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const SessionChecker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SessionChecker extends StatefulWidget {
  const SessionChecker({super.key});

  @override
  State<SessionChecker> createState() => _SessionCheckerState();
}

class _SessionCheckerState extends State<SessionChecker> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api-litera.vercel.app/auth/keep-login'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoggedIn = true;
        });
      } else {
        await prefs.remove('token');
      }
    } catch (_) {
      await prefs.remove('token');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isLoggedIn ? const HomePage() : const LoginPage();
  }
}
