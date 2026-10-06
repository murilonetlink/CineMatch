class Media {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final String type; // 'movie' or 'tv'

  Media({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.type,
  });

  factory Media.fromTmdb(Map<String, dynamic> json, String type) {
    return Media(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      type: type,
    );
  }
}
