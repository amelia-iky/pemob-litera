class Book {
  final String id;
  final String title;
  final String coverImage;
  final String category;
  final String details;
  final String publisher;

  Book({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.category,
    required this.details,
    required this.publisher,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      coverImage: json['cover_image'],
      category: json['category']['name'],
      details: 'Harga: ${json['details']['price']}, '
               'Halaman: ${json['details']['total_pages']}, '
               'Terbit: ${json['details']['published_date']}',
      publisher: json['publisher'],
    );
  }
}
