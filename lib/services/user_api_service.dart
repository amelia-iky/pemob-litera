import 'dart:convert';
import 'dart:io';
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
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  static Future<String> updateUserProfile({
    required String name,
    required String email,
    File? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('Token not found');

    final url = Uri.parse('https://api-litera.vercel.app/user/profile-update');

    final request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['email'] = email;

    if (profileImage != null) {
      final fileStream = http.ByteStream(profileImage.openRead());
      final length = await profileImage.length();

      request.files.add(
        http.MultipartFile(
          'profileImages',
          fileStream,
          length,
          filename: profileImage.path.split('/').last,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return 'Profile updated successfully';
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      final msg =
          jsonDecode(response.body)['message'] ?? 'Failed to update profile';
      throw Exception(msg);
    }
  }
}
