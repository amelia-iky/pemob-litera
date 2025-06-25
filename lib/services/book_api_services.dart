import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_models.dart';

class BookApiService {
  static const String baseUrl = 'https://bukuacak-9bdcb4ef2605.herokuapp.com/api/v1/book';

  static Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl?keyword=$query'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> booksJson = data['books'];
      return booksJson.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

  static Future<Book> fetchBookById(String id) async {
    final response = await http.get(
      Uri.parse('https://bukuacak-9bdcb4ef2605.herokuapp.com/api/v1/book?_id=$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Book.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail buku');
    }
  }
}
