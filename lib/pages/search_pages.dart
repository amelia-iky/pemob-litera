import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/book_api_services.dart';
import '../widgets/book_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Book>>? _searchResults;

  void _search() {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      setState(() {
        _searchResults = BookApiService.searchBooks(keyword);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cari Buku")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan judul, penulis...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _searchResults == null
                  ? const Center(child: Text('Silakan masukkan kata kunci untuk mencari.'))
                  : FutureBuilder<List<Book>>(
                      future: _searchResults,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Buku tidak ditemukan.'));
                        } else {
                          final books = snapshot.data!;
                          return ListView.builder(
                            itemCount: books.length,
                            itemBuilder: (context, index) => BookCard(book: books[index]),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
