import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../pages/book_detail_pages.dart';
import '../services/user_api_service.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final bool isFavorite;
  final bool isSaved;
  final VoidCallback? onFavoriteToggled;
  final VoidCallback? onSavedToggled;

  const BookCard({
    super.key,
    required this.book,
    this.isFavorite = false,
    this.isSaved = false,
    this.onFavoriteToggled,
    this.onSavedToggled,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  late bool isFavorited;
  late bool isSaved;
  String? favoriteId;
  String? savedId;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.isFavorite;
    isSaved = widget.isSaved;
  }

  Future<void> _toggleFavorite() async {
    try {
      if (isFavorited) {
        final favorites = await UserApiService.getFavorites();
        final match = favorites.firstWhere(
          (item) => item['bookId'] == widget.book.id,
          orElse: () => null,
        );
        if (match != null) {
          await UserApiService.deleteFavorite(match['id']);
        }

        setState(() {
          isFavorited = false;
          favoriteId = null;
        });
      } else {
        final id = await UserApiService.addFavorite(
          bookId: widget.book.id,
          title: widget.book.title,
          author: widget.book.author,
          tags: widget.book.tags.map((tag) => tag.name).toList(),
          coverImage: widget.book.coverImage,
        );
        setState(() {
          isFavorited = true;
          favoriteId = id;
        });
      }

      widget.onFavoriteToggled?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle favorite: $e')));
    }
  }

  Future<void> _toggleSaved() async {
    try {
      if (isSaved) {
        final saved = await UserApiService.getSaved();
        final match = saved.firstWhere(
          (item) => item['bookId'] == widget.book.id,
          orElse: () => null,
        );
        if (match != null) {
          await UserApiService.deleteSaved(match['id']);
        }

        setState(() {
          isSaved = false;
          savedId = null;
        });
      } else {
        final id = await UserApiService.addSaved(
          bookId: widget.book.id,
          title: widget.book.title,
          author: widget.book.author,
          price: widget.book.price,
          coverImage: widget.book.coverImage,
        );
        setState(() {
          isSaved = true;
          savedId = id;
        });
      }

      widget.onSavedToggled?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isSaved ? 'Book saved' : 'Save removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle saved: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailPage(bookId: widget.book.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.book.coverImage.isNotEmpty
                          ? widget.book.coverImage
                          : 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      height: 150,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.book.price,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleSaved,
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.amber : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
