import '../models/book.dart';
import '../services/book_api_service.dart';

class BookRepository {
  Future<List<Book>> getAllBooks() async {
    return await BookApiService.fetchBooks();
  }
}
