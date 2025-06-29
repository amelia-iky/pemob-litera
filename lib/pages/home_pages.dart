import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../models/genre_models.dart';
import '../models/user_models.dart';
import '../services/book_api_service.dart';
import '../services/user_api_service.dart';
import '../widgets/book_card.dart';
import '../widgets/book_category.dart';
import '../widgets/book_search.dart';
import '../widgets/custom_drawer.dart';

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

  // Favorites
  Set<String> _favoriteBookIds = {};
  late Future<void> _initData;

  Future<UserProfile> _fetchUserProfile() {
    return UserApiService.fetchUserProfile();
  }

  @override
  void initState() {
    super.initState();
    _initData = _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    _genreFuture = BookApiService.fetchGenreStats();
    try {
      final favorites = await UserApiService.getFavorites();
      _favoriteBookIds = favorites
          .map<String>((f) => f['bookId'] as String)
          .toSet();
    } catch (e) {
      debugPrint('Failed to fetch favorites: $e');
      _favoriteBookIds = {};
    }
  }

  void _refreshFavorites() async {
    try {
      final favorites = await UserApiService.getFavorites();
      setState(() {
        _favoriteBookIds = favorites
            .map<String>((f) => f['bookId'] as String)
            .toSet();
      });
    } catch (e) {
      debugPrint('Failed to refresh favorites: $e');
    }
  }

  Set<String> favoriteBookIds = {};

  // Future<void> _loadFavoriteBookIds() async {
  //   try {
  //     final favorites = await UserApiService.getFavorites();
  //     setState(() {
  //       favoriteBookIds = favorites
  //           .map<String>((item) => item['bookId'] as String)
  //           .toSet();
  //     });
  //   } catch (e) {
  //     debugPrint('Error loading favorite IDs: $e');
  //   }
  // }

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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xfff8c9d3),
      ),
      drawer: CustomDrawer(
        fetchUserProfile: _fetchUserProfile,
        onProfileUpdated: () {
          setState(() {});
        },
        onFavoritesChanged: _refreshFavorites,
      ),

      body: FutureBuilder<void>(
        future: _initData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          return Column(
            children: [
              // Search Bar
              BookSearch(
                controller: _searchController,
                onSearch: _performSearch,
                onClear: () {
                  _searchController.clear();
                  _performSearch('');
                },
              ),
              Expanded(
                child: _isSearching && _searchResults != null
                    ? FutureBuilder<List<Book>>(
                        future: _searchResults,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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
                              final book = books[i];
                              return BookCard(
                                book: book,
                                isFavorite: _favoriteBookIds.contains(book.id),
                                onFavoriteToggled: _refreshFavorites,
                              );
                            },
                          );
                        },
                      )
                    : FutureBuilder<List<GenreStat>>(
                        future: _genreFuture,
                        builder: (context, genreSnapshot) {
                          if (genreSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (genreSnapshot.hasError) {
                            return Center(
                              child: Text('Error: ${genreSnapshot.error}'),
                            );
                          } else if (!genreSnapshot.hasData ||
                              genreSnapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No genres found.'),
                            );
                          }

                          final genres = genreSnapshot.data!;
                          final totalPages = (genres.length / genresPerPage)
                              .ceil();
                          final pagedGenres = genres
                              .skip(currentPage * genresPerPage)
                              .take(genresPerPage)
                              .toList();

                          // Book Category
                          return BookCategory(
                            pagedGenres: pagedGenres,
                            currentPage: currentPage,
                            totalPages: totalPages,
                            onPrevPage: () => setState(() => currentPage--),
                            onNextPage: () => setState(() => currentPage++),
                            bookFutures: _bookFutures,
                            favoriteBookIds: _favoriteBookIds,
                            onFavoriteToggled: _refreshFavorites,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
