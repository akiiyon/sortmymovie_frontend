// lib/services/movie_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  final String baseUrl = '${BACKEND_BASE_URL}/api/movies';

  // Helper to create authenticated headers
  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // 1. Fetch the Next Movie Suggestion
  // Future<Movie> fetchNextSuggestion(String token) async {

  // }

  // 2. Search for movies using the search bar
  Future<List<Movie>> searchMovies(String query) async {
    // Note: Search is NOT authenticated in our backend design
    final response = await http.get(Uri.parse('$baseUrl/search?query=$query'));
    print(response.body);

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

  // 4. Fetch the user's full saved list
  Future<List<Movie>> fetchSavedMovies(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/saved'), // Assuming endpoint is /api/movies/saved
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      
      // The backend should return the Movie object structure from your DB
      return jsonList.map((json) => Movie.fromJson(json)).toList(); 
    } else {
      throw Exception('Failed to load saved list.');
    }
  }

//airecommendations

Future<List<String>> fetchAiRecommendations(String token) async {
  // Hardcoding service to 'groq' as requested
  final String url = '$BACKEND_BASE_URL/api/movies/recommendations?service=groq';

  final response = await http.get(
    Uri.parse(url),
    headers: _authHeaders(token),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    // Extract the list of titles from the "recommendations" key
    final List<dynamic> titles = data['recommendations'];
    return titles.map((title) => title.toString()).toList();
  } else {
    throw Exception('Failed to fetch recommendations: ${response.body}');
  }
}
}
