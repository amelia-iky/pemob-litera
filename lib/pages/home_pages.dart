import 'package:flutter/material.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';
import '../widgets/book_card.dart';

class HomePage extends StatelessWidget {
  final BookRepository bookRepository = BookRepository();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Litera')),
      body: FutureBuilder<List<Book>>(
        future: bookRepository.getAllBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books found.'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: snapshot.data!.map((book) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: BookCard(book: book),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
