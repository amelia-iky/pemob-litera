import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../models/genre_models.dart';
import '../services/genre_api_services.dart';
import '../services/book_api_services.dart'; 
import '../widgets/book_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<GenreStat>> _genreFuture;
  final Map<String, Future<List<Book>>> _bookFutures = {};

  final TextEditingController _searchController = TextEditingController();
  Future<List<Book>>? _searchResults;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _genreFuture = GenreApiService.fetchGenreStats();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _searchResults = BookApiService.searchBooks(query);
      _isSearching = true;
    });
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
              decoration: BoxDecoration(color: Color(0xFFFFC0CB)),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari buku...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isSearching && _searchResults != null
                ? FutureBuilder<List<Book>>(
                    future: _searchResults,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No books found.'));
                      }

                      final books = snapshot.data!
                          .where((b) => b.coverImage.isNotEmpty)
                          .toList();

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, i) {
                          return BookCard(book: books[i]);
                        },
                      );
                    },
                  )
                : FutureBuilder<List<GenreStat>>(
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
                          _bookFutures.putIfAbsent(
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
          ),
        ],
      ),
    );
  }
}
