import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/genre_models.dart';
import '../models/book_models.dart';

class GenreApiService {
  static const String baseUrl = 'https://bukuacak-9bdcb4ef2605.herokuapp.com/api/v1';

  static Future<List<GenreStat>> fetchGenreStats() async {
    // Fetch genre statistics
    final response = await http.get(Uri.parse('$baseUrl/stats/genre'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> statsJson = data['genre_statistics'];
      return statsJson.map((json) => GenreStat.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load genre statistics');
    }
  }

  // Fetch books by genre
  static Future<List<Book>> fetchBooksByGenre(String genre) async {
    final response = await http.get(Uri.parse('$baseUrl/book?genre=$genre'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> booksJson = data['books'];
      return booksJson.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books for genre $genre');
    }
  }
}
