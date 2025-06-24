class Book {
  final String id;
  final String title;
  final String coverImage;
  final String author;
  final String authorUrl;
  final String category;
  final String categoryUrl;
  final String summary;
  final String price;
  final String totalPages;
  final String size;
  final String publishedDate;
  final String format;
  final String publisher;

  Book({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.author,
    required this.authorUrl,
    required this.category,
    required this.categoryUrl,
    required this.summary,
    required this.price,
    required this.totalPages,
    required this.size,
    required this.publishedDate,
    required this.format,
    required this.publisher,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final details = json['details'] ?? {};
    final author = json['author'] ?? {};
    final category = json['category'] ?? {};

    return Book(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      coverImage: json['cover_image']?.toString() ?? '',
      author: author['name']?.toString() ?? 'Unknown',
      authorUrl: author['url']?.toString() ?? '',
      category: category['name']?.toString() ?? 'Unknown',
      categoryUrl: category['url']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      price: details['price']?.toString() ?? '',
      totalPages: details['total_pages']?.toString() ?? '',
      size: details['size']?.toString() ?? '',
      publishedDate: details['published_date']?.toString() ?? '',
      format: details['format']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
    );
  }
}
