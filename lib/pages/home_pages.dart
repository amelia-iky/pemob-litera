import 'package:flutter/material.dart';
import './profile_pages.dart';
import '../models/book_models.dart';
import '../models/genre_models.dart';
import '../models/user_models.dart';
import '../services/book_api_service.dart';
import '../services/genre_api_service.dart';
import '../services/user_api_service.dart';
import '../widgets/book_card.dart';
import '../widgets/book_category.dart';

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
        title: const Text(
          'Litera',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
                  return const SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: DrawerHeader(
                      decoration: BoxDecoration(color: Color(0xfff8c9d3)),
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: DrawerHeader(
                      decoration: BoxDecoration(color: Color(0xfff8c9d3)),
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Text(
                          'User tidak ditemukan',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  );
                }

                final user = snapshot.data!;
                final imageUrl = user.profileImages.isNotEmpty
                    ? user.profileImages.first.url
                    : null;

                return SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xfff8c9d3)),
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          backgroundImage: imageUrl != null
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () async {
                      Navigator.pop(context);

                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );

                      if (updated == true) {
                        setState(() {
                          _userProfile = UserApiService.fetchUserProfile();
                        });
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  const ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text('Favorite'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text('Saved'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 32),
              child: Column(
                children: [
                  Text(
                    'Developed with ❤️ by Amelia Rizky Yuniar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                      if (genreSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (genreSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${genreSnapshot.error}'),
                        );
                      } else if (!genreSnapshot.hasData ||
                          genreSnapshot.data!.isEmpty) {
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
                                if (genreSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (genreSnapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${genreSnapshot.error}',
                                    ),
                                  );
                                } else if (!genreSnapshot.hasData ||
                                    genreSnapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text('No genres found.'),
                                  );
                                }

                                final genres = genreSnapshot.data!;
                                final totalPages =
                                    (genres.length / genresPerPage).ceil();
                                final pagedGenres = genres
                                    .skip(currentPage * genresPerPage)
                                    .take(genresPerPage)
                                    .toList();

                                return GenreBookList(
                                  pagedGenres: pagedGenres,
                                  currentPage: currentPage,
                                  totalPages: totalPages,
                                  onPrevPage: () =>
                                      setState(() => currentPage--),
                                  onNextPage: () =>
                                      setState(() => currentPage++),
                                  bookFutures: _bookFutures,
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
