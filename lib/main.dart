import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gramedia Book Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BookStorePage(),
    );
  }
}

class BookStorePage extends StatelessWidget {
  const BookStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gramedia Book Store'),
      ),
      body: ListView.builder(
        itemCount: 10, // 10 baris
        itemBuilder: (context, rowIndex) {
          return SizedBox(
            height: MediaQuery.of(context).size.width / 2, // Tinggi item proporsional ke lebar layar
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // 3 item per baris
              itemBuilder: (context, colIndex) {
                double itemWidth = MediaQuery.of(context).size.width / 2.5; // Responsive width

                return Container(
                  width: itemWidth,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100 * ((rowIndex + colIndex) % 9)],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Book ${rowIndex + 1} - ${colIndex + 1}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
