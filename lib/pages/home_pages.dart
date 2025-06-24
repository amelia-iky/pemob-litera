import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../models/genre_models.dart';
import '../services/genre_api_services.dart';
import '../widgets/book_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<GenreStat>> _genreFuture;
  final Map<String, Future<List<Book>>> _bookFutures = {};

  @override
  void initState() {
    super.initState();
    _genreFuture = GenreApiService.fetchGenreStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Litera')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favorite'),
            ),
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Save'),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<GenreStat>>(
        future: _genreFuture,
        builder: (context, genreSnapshot) {
          if (genreSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (genreSnapshot.hasError) {
            return Center(child: Text('Error: ${genreSnapshot.error}'));
          } else if (!genreSnapshot.hasData || genreSnapshot.data!.isEmpty) {
            return const Center(child: Text('No genres found.'));
          }

          final genres = genreSnapshot.data!;
          return ListView.builder(
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              // simpan future jika belum ada
              _bookFutures.putIfAbsent(
                  genre.genre, () => GenreApiService.fetchBooksByGenre(genre.genre));

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
                      future: _bookFutures[genre.genre],
                      builder: (context, bookSnapshot) {
                        if (bookSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (bookSnapshot.hasError) {
                          return Center(child: Text('Error loading books'));
                        } else if (!bookSnapshot.hasData || bookSnapshot.data!.isEmpty) {
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
            },
          );
        },
      ),
    );
  }
}
