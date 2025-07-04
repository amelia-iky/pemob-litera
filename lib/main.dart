import 'package:flutter/material.dart';
import 'pages/signin_pages.dart';
import 'pages/home_pages.dart';
import 'services/auth_api_service.dart';

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
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors.pinkAccent[100],
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xfff8c9d3), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xfff8c9d3), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const SessionChecker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Session checker
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
    _initSession();
  }

  Future<void> _initSession() async {
    final result = await AuthApiService.keepLogin();
    setState(() {
      _isLoggedIn = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icon/app_icon.png', width: 120, height: 120),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Color(0xfff8c9d3)),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const HomePage() : const SignInPage();
  }
}
