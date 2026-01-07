// lib/models/movie.dart
class Movie {
  final int id;
  final String title;
  final String? posterUrl;
  final List<String> genres;
  final int? releaseYear;

  Movie({
    required this.id,
    required this.title,
    this.posterUrl,
    this.genres = const [],
    this.releaseYear,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Note: 'movie_id' from backend maps to 'id' here
    return Movie(
      id:
          json['tmdb_id'] ??
          json['id'], // Handle both backend and direct TMDB search results
      title: json['title'] ?? 'Unknown Title',
      // The backend returns the full URL, direct TMDB search gives only the path
      posterUrl:
          json['poster_url'] ??
          (json['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
              : null),
      genres: List<String>.from(json['genres'] ?? []),
      releaseYear: json['release_year'] != null
          ? int.parse(json['release_year'])
          : (json['release_date'] != null
                ? DateTime.tryParse(json['release_date'])?.year
                : null),
    );
  }
}
