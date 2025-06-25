import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Detail Buku',
          style: TextStyle(
            color: Colors.black, 
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: const Color(0xFFFFC0CB),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
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
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            book.coverImage,
                            height: 500,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://via.placeholder.com/150',
                                height: 300,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Penulis: ${book.author}',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Kategori: ${book.category}',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Penerbit: ${book.publisher}',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 16),
                      const Text(
                        'DESKRIPSI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.summary.isNotEmpty
                            ? book.summary
                            : 'Tidak ada deskripsi tersedia.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),

                      // Book Details
                      const Text(
                        'DETAIL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Text('Harga: ${book.price}'),
                          Text('Halaman: ${book.totalPages}'),
                          Text('Ukuran: ${book.size}'),
                          Text('Format: ${book.format}'),
                          Text('Terbit: ${book.publishedDate}'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      if (book.tags.isNotEmpty) ...[
                        const Text(
                          'Tags:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: book.tags.map((tag) {
                            return Chip(
                              label: Text(tag.name),
                              backgroundColor: Colors.pink[100],
                              elevation: 0,
                              shape: const StadiumBorder(
                                side: BorderSide.none,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Buy Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[500],
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final url = book.buyLinks.isNotEmpty ? book.buyLinks.first.url : null;

                    if (url != null && url.isNotEmpty) {
                      try {
                        final uri = Uri.parse(url);
                        final canLaunch = await canLaunchUrl(uri);
                        if (canLaunch) {
                          await launchUrl(uri, mode: LaunchMode.platformDefault);
                        } else {
                          throw 'Cannot launch';
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link tidak dapat dibuka')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link tidak tersedia')),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shopping_cart, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Beli Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
