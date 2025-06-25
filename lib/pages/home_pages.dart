import 'package:flutter/material.dart';
import './profile_pages.dart';
import '../models/book_models.dart';
import '../models/genre_models.dart';
import '../models/user_models.dart';
import '../services/book_api_services.dart';
import '../services/genre_api_services.dart';
import '../services/user_api_services.dart';
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

  // Pagination
  int currentPage = 0;
  final int genresPerPage = 5;

  late Future<UserProfile> _userProfile;

  @override
  void initState() {
    super.initState();
    _genreFuture = GenreApiService.fetchGenreStats();
    _userProfile = UserApiService.fetchUserProfile();
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Litera',
          style: TextStyle(
            color: Colors.black,
           fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: const Color(0xfff8c9d3),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            FutureBuilder<UserProfile>(
              future: _userProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xfff8c9d3)),
                    child: Center(child: CircularProgressIndicator(color: Colors.white)),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xfff8c9d3)),
                    child: Text(
                      'User tidak ditemukan',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                final user = snapshot.data!;
                final imageUrl = user.profileImages.isNotEmpty ? user.profileImages.first.url : null;

                return DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xfff8c9d3)),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                        child: imageUrl == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                      Text(
                        user.name,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
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
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 32),
              child: Column(
                children: [
                  Text(
                    'Developed by Amelia Rizky Yuniar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
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
                      final totalPages = (genres.length / genresPerPage).ceil();
                      final pagedGenres = genres
                          .skip(currentPage * genresPerPage)
                          .take(genresPerPage)
                          .toList();

                      return Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<List<GenreStat>>(
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
                                final totalPages = (genres.length / genresPerPage).ceil();
                                final pagedGenres = genres
                                    .skip(currentPage * genresPerPage)
                                    .take(genresPerPage)
                                    .toList();

                                return ListView.builder(
                                  itemCount: pagedGenres.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index < pagedGenres.length) {
                                      final genre = pagedGenres[index];
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
                                                if (bookSnapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(child: CircularProgressIndicator());
                                                } else if (bookSnapshot.hasError) {
                                                  return Center(child: Text('Error loading books'));
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
                                      // Pagination sebagai item terakhir
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.arrow_back),
                                              onPressed: currentPage > 0
                                                  ? () => setState(() => currentPage--)
                                                  : null,
                                            ),
                                            Text('Page ${currentPage + 1} of $totalPages'),
                                            IconButton(
                                              icon: const Icon(Icons.arrow_forward),
                                              onPressed: currentPage < totalPages - 1
                                                  ? () => setState(() => currentPage++)
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
