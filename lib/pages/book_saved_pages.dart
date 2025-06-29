import 'package:flutter/material.dart';
import '../services/user_api_service.dart';
import '../pages/book_detail_pages.dart';

class SavedPage extends StatefulWidget {
  final VoidCallback? onSavedChanged;
  const SavedPage({super.key, this.onSavedChanged});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<dynamic> _savedBooks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedBooks();
  }

  Future<void> _loadSavedBooks() async {
    try {
      final saved = await UserApiService.getSaved();
      setState(() {
        _savedBooks = saved;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSaved(String savedId) async {
    try {
      await UserApiService.deleteSaved(savedId);
      setState(() {
        _savedBooks.removeWhere((item) => item['id'] == savedId);
      });

      widget.onSavedChanged?.call();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed from saved books')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove saved book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Saved Books',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xfff8c9d3),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _savedBooks.isEmpty
          ? const Center(
              child: Text(
                'No saved books',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: _savedBooks.length,
              itemBuilder: (context, index) {
                final book = _savedBooks[index];
                final imageUrl = book['coverImage'] ?? '';
                final price = book['price'] ?? '';

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailPage(bookId: book['bookId']),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                book['author'] ?? '',
                                style: const TextStyle(fontSize: 13),
                              ),
                              if (price.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  price,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteSaved(book['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
