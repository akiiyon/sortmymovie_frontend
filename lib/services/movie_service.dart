// lib/services/movie_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  final String baseUrl = 'http://localhost:4000/api/movies';
  final String suggestionUrl = 'http://localhost:4000/api/suggestions';

  // Helper to create authenticated headers
  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // 1. Fetch the Next Movie Suggestion
  Future<Movie> fetchNextSuggestion(String token) async {
    final response = await http.get(
      Uri.parse('$suggestionUrl/next'),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      // The backend returns a single Movie object
      return Movie.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load suggestion: ${response.body}');
    }
  }

  // 2. Search for movies using the search bar
  Future<List<Movie>> searchMovies(String query) async {
    // Note: Search is NOT authenticated in our backend design
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/movies/search?query=$query'),
    );

    if (response.statusCode == 200) {
      // The backend returns an array of results from TMDB
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to perform search.');
    }
  }

  // 3. Save a movie to the user's list
  Future<void> saveMovie(String token, int tmdbId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save'),
      headers: _authHeaders(token),
      body: jsonEncode({'tmdb_id': tmdbId}),
    );

    if (response.statusCode != 201 && response.statusCode != 409) {
      // 409 is 'Movie is already in your list', which is acceptable
      throw Exception(
        'Failed to save movie: ${jsonDecode(response.body)['error']}',
      );
    }
  }
}
