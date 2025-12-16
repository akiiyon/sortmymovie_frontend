// lib/providers/movie_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart'; // Needed for CardSwiperDirection
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();
  List<Movie> _suggestionQueue = [];
  bool _isLoading = false;

  List<Movie> get suggestionQueue => _suggestionQueue;
  bool get isLoading => _isLoading;

  // --- Internal Fetch Logic ---
  
  // Fetches a single suggestion and adds it to the queue
  Future<void> fetchNextSuggestion(String token) async {
    try {
      final movie = await _movieService.fetchNextSuggestion(token);
      
      // Ensure we don't add duplicates (in case the AI recommends the same thing twice)
      if (!_suggestionQueue.any((m) => m.id == movie.id)) {
        _suggestionQueue.add(movie);
        notifyListeners();
        debugPrint('Fetched new suggestion: ${movie.title}');
      }
    } catch (e) {
      debugPrint('Error fetching next suggestion: $e');
    }
  }

  // Loads initial set of suggestions (e.g., 3 cards)
  Future<void> loadInitialSuggestions(String token) async {
    if (_suggestionQueue.isNotEmpty || _isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    // Fetch multiple suggestions to populate the initial queue
    await fetchNextSuggestion(token);
    await fetchNextSuggestion(token);
    await fetchNextSuggestion(token);
    
    _isLoading = false;
    notifyListeners();
  }

  // --- Interaction Logic ---
  
  // Removes the top card from the queue
  void _removeCurrentSuggestion() {
    if (_suggestionQueue.isNotEmpty) {
      _suggestionQueue.removeAt(0);
      notifyListeners();
    }
  }
  
  // Records the user's swipe/interaction and manages the queue refill
  Future<void> recordInteraction(
      String token, 
      Movie movie, 
      CardSwiperDirection direction) async {
    
    // 1. If it was a 'Like' (Swipe Right), save it to the DB
    if (direction == CardSwiperDirection.right) {
      try {
        await _movieService.saveMovie(token, movie.id);
        debugPrint('Movie ${movie.title} saved!');
      } catch (e) {
        debugPrint('Failed to save movie: $e');
      }
    } else {
      // If it was a 'Skip' (Swipe Left or Button Press), 
      // the backend handles marking it as 'viewed' upon fetch.
      debugPrint('Movie ${movie.title} skipped.');
    }

    // 2. Remove the current movie and notify listeners
    _removeCurrentSuggestion();
    
    // 3. Proactively fetch the next movie if the queue is running low
    if (_suggestionQueue.length < 2) { 
        await fetchNextSuggestion(token);
    }
  }
}