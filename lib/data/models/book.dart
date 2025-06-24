class Book {
  final String id;
  final String title;
  final String coverImage;
  final String category;

  Book({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.category,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      coverImage: json['cover_image'],
      category: json['category']['name'],
    );
  }
}
