// genre_book_list.dart
import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../models/genre_models.dart';
import '../services/genre_api_service.dart';
import 'book_card.dart';

class GenreBookList extends StatelessWidget {
  final List<GenreStat> pagedGenres;
  final int currentPage;
  final int totalPages;
  final void Function() onPrevPage;
  final void Function() onNextPage;
  final Map<String, Future<List<Book>>> bookFutures;

  const GenreBookList({
    super.key,
    required this.pagedGenres,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevPage,
    required this.onNextPage,
    required this.bookFutures,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pagedGenres.length + 1,
      itemBuilder: (context, index) {
        if (index < pagedGenres.length) {
          final genre = pagedGenres[index];
          bookFutures.putIfAbsent(
            genre.genre,
            () => GenreApiService.fetchBooksByGenre(genre.genre),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        genre.genre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${genre.count} buku',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Book>>(
                  future: bookFutures[genre.genre],
                  builder: (context, bookSnapshot) {
                    if (bookSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (bookSnapshot.hasError) {
                      return const Center(child: Text('Error loading books'));
                    } else if (!bookSnapshot.hasData ||
                        bookSnapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('No books in this genre.'),
                      );
                    }

                    final books = bookSnapshot.data!
                        .where((b) => b.coverImage.isNotEmpty)
                        .toList();

                    return SizedBox(
                      height: 320,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: books.length,
                        itemBuilder: (context, i) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: BookCard(book: books[i]),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: currentPage > 0 ? onPrevPage : null,
                ),
                Text('Page ${currentPage + 1} of $totalPages'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: currentPage < totalPages - 1 ? onNextPage : null,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
