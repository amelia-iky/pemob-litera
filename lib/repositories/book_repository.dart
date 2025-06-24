import '../models/book_models.dart';
import '../services/book_api_services.dart';

class BookRepository {
  Future<List<Book>> getAllBooks() async {
    return await BookApiService.fetchBooks();
  }
}
