import 'package:flutter/material.dart';
import '../models/book_models.dart';

class BookCard extends StatefulWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool isFavorited = false;
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Konten utama
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar buku
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.book.coverImage,
                    fit: BoxFit.cover,
                    height: 170,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        height: 170,
                        width: double.infinity,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Judul
                Text(
                  widget.book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // Author
                Text(
                  widget.book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),

                const SizedBox(height: 40), // ruang untuk tombol
              ],
            ),
          ),

          // Tombol aksi di kanan bawah
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorited = !isFavorited;
                    });
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isSaved = !isSaved;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
