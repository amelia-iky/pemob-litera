import 'package:flutter/material.dart';
import 'book_card.dart';
import '../models/book_models.dart';
import '../models/genre_models.dart';
import '../services/book_api_service.dart';

class BookCategory extends StatelessWidget {
  final List<GenreStat> pagedGenres;
  final int currentPage;
  final int totalPages;
  final void Function() onPrevPage;
  final void Function() onNextPage;
  final Map<String, Future<List<Book>>> bookFutures;
  final Set<String> favoriteBookIds;
  final VoidCallback onFavoriteToggled;

  const BookCategory({
    super.key,
    required this.pagedGenres,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevPage,
    required this.onNextPage,
    required this.bookFutures,
    required this.favoriteBookIds,
    required this.onFavoriteToggled,
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
            () => BookApiService.fetchBooksByGenre(genre.genre),
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
                        '${genre.count} books',
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
                          final book = books[i];

                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: BookCard(
                              book: book,
                              isFavorite: favoriteBookIds.contains(book.id),
                              onFavoriteToggled: onFavoriteToggled,
                            ),
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
          // Pagination controls
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
