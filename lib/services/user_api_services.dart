import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_models.dart';

class UserApiService {
  static Future<UserProfile> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('Token not found');

    final url = Uri.parse('https://api-litera.vercel.app/user/profile');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return UserProfile.fromJson(data);
    } else {
      throw Exception('Gagal mengambil profil user');
    }
  }
}
