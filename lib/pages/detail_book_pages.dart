import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/book_api_services.dart';

class DetailBookPage extends StatefulWidget {
  final String bookId;

  const DetailBookPage({super.key, required this.bookId});

  @override
  State<DetailBookPage> createState() => _DetailBookPageState();
}

class _DetailBookPageState extends State<DetailBookPage> {
  late Future<Book> _bookDetail;

  @override
  void initState() {
    super.initState();
    _bookDetail = BookApiService.fetchBookById(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: FutureBuilder<Book>(
        future: _bookDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Buku tidak ditemukan.'));
          }

          final book = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    book.coverImage.isNotEmpty
                        ? book.coverImage
                        : 'https://via.placeholder.com/150',
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  book.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Penulis: ${book.author}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: ${book.category}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Text(
                  book.summary.isNotEmpty
                      ? book.summary
                      : 'Tidak ada deskripsi tersedia.',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
