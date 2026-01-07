// lib/providers/movie_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();
  List<Movie> _suggestionQueue = [];

  //saved movies code
  List<Movie> _savedMovies = [];

  bool _isSavedMoviesLoading = false;
  List<Movie> get savedMovies => _savedMovies;
  bool get isSavedMoviesLoading => _isSavedMoviesLoading;

  bool _isLoading = false;

  List<Movie> get suggestionQueue => _suggestionQueue;
  bool get isLoading => _isLoading;

  // ➕ ADDED: Local storage for rejected movie IDs (Solution 1)
  final Set<int> _rejectedMovieIds = {};

  Future<void> fetchSavedMovies(String token) async {
    _isSavedMoviesLoading = true;
    notifyListeners();

    try {
      final movies = await _movieService.fetchSavedMovies(token);
      _savedMovies = movies;
      print(_savedMovies);
    } catch (e) {
      debugPrint("Error fetching saved: $e");
    } finally {
      _isSavedMoviesLoading = false;
      notifyListeners();
    }
  }

  // --- Interaction Logic ---

  // Removes the top card from the queue
  void _removeCurrentSuggestion() {
    if (_suggestionQueue.isNotEmpty) {
      _suggestionQueue.removeAt(0);
      notifyListeners();
    }
  }

  //airecommendations

  List<String> _aiRecommendations = [];
  bool _isAiLoading = false;

  List<String> get aiRecommendations => _aiRecommendations;
  bool get isAiLoading => _isAiLoading;

  Future<void> getAiRecommendations(String token) async {
    _isAiLoading = true;
    notifyListeners(); // Shows the loading spinner
    print("step 11");
    try {
      // ➕ ADDED: Convert the Set of rejected IDs to a List
      List<int> excludedIds = _rejectedMovieIds.toList();
      print("Sending Blacklist to API: $excludedIds");

      // 🔥 CHANGED: Pass the excludedIds to the service
      // Note: You must update your MovieService.fetchAiRecommendations to accept this list!
      List<String> aiTitles = await _movieService.fetchAiRecommendations(
        token,
        excludedIds,
      );

      print("step 1");

      List<Movie> newMovies = [];

      // 3. Loop through each title and fetch its poster/details from TMDB
      for (String title in aiTitles) {
        try {
          // Search TMDB for this specific title
          final searchResults = await _movieService.searchMovies(title);
          print("step2");
          // If TMDB found a match, add the first result to our list
          if (searchResults.isNotEmpty) {
            newMovies.add(searchResults.first);
          }
        } catch (e) {
          debugPrint("Could not find poster for '$title': $e");
        }
      }

      // 4. Add all the valid movie objects to the main queue
      _suggestionQueue.addAll(newMovies);
    } catch (e) {
      debugPrint("AI Recommendation Error: $e");
    } finally {
      _isAiLoading = false;
      notifyListeners(); // Hides spinner and shows the new cards
    }
  }

  // Records the user's swipe/interaction and manages the queue refill
  Future<void> recordInteraction(
    String token,
    Movie movie,
    CardSwiperDirection direction,
  ) async {
    // 1. If it was a 'Like' (Swipe Right), save it to the DB
    if (direction == CardSwiperDirection.right) {
      try {
        await _movieService.saveMovie(token, movie.id);
        print(movie.id);
        debugPrint('Movie ${movie.title} saved!');
      } catch (e) {
        debugPrint('Failed to save movie: $e');
      }
    }
    // 🔥 CHANGED: Add logic for Swipe Left (Reject)
    else if (direction == CardSwiperDirection.left) {
      try {
        await _movieService.rejectMovie(token, movie.id, movie.title);
        // Add this movie ID to our local blacklist
        _rejectedMovieIds.add(movie.id);
        debugPrint(
          'Movie ${movie.title} (ID: ${movie.id}) rejected and added to blacklist.',
        );
      } catch (e) {
        debugPrint('Failed to reject movie: $e');
      }
    } else {
      debugPrint('Movie ${movie.title} skipped (other direction).');
    }

    // 2. Remove the current movie and notify listeners
    _removeCurrentSuggestion();

    // 3. Proactively fetch the next movie if the queue is running low
    if (_suggestionQueue.length < 2) {
      // await fetchNextSuggestion(token);
    }
  }
}
