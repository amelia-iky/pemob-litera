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
  final List<Tag> tags;
  final List<BuyLink> buyLinks;

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
    required this.tags,
    required this.buyLinks,
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
      tags: (json['tags'] as List<dynamic>? ?? []).map((tag) => Tag.fromJson(tag)).toList(),
      buyLinks: (json['buy_links'] as List<dynamic>? ?? []).map((link) => BuyLink.fromJson(link)).toList(),
    );
  }
}

class Tag {
  final String name;
  final String url;

  Tag({
    required this.name,
    required this.url,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class BuyLink {
  final String store;
  final String url;

  BuyLink({
    required this.store,
    required this.url,
  });

  factory BuyLink.fromJson(Map<String, dynamic> json) {
    return BuyLink(
      store: json['store']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}
