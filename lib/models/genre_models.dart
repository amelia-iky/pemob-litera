class GenreStat {
  final String genre;
  final int count;

  GenreStat({required this.genre, required this.count});

  factory GenreStat.fromJson(Map<String, dynamic> json) {
    return GenreStat(
      genre: json['genre']?.toString() ?? 'Unknown',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }
}
