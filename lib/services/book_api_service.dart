import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookApiService {
  static const String baseUrl = 'https://bukuacak-9bdcb4ef2605.herokuapp.com/api/v1/book';

  static Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> booksJson = data['books'];

      return booksJson.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}
