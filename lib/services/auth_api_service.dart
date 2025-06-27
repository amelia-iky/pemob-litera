import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  // Signup
  static Future<void> signup({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('https://api-litera.vercel.app/auth/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final msg = jsonDecode(response.body)['message'] ?? 'Failed to Sign Up';
      throw Exception(msg);
    }
  }

  // Signin
  static Future<void> signin({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('https://api-litera.vercel.app/auth/signin');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'password': password.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final token = json['token'];
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', token);
    } else {
      final msg = jsonDecode(response.body)['message'] ?? 'Failed to Signin';
      throw Exception(msg);
    }
  }

  // Signout
  static Future<void> signout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final url = Uri.parse('https://api-litera.vercel.app/auth/signout');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final msg = jsonDecode(response.body)['message'] ?? 'Failed to Signout';
        throw Exception(msg);
      }
    } else {
      throw Exception('Token not found');
    }

    await prefs.remove('token');
  }
}
