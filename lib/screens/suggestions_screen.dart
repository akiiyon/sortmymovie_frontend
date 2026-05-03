// lib/screens/suggestions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import 'movie_detail_screen.dart';
import '../widgets/movie_card.dart';
import '../widgets/searchbar_widget.dart';

class SuggestionsView extends StatelessWidget {
  const SuggestionsView({super.key});

  // Helper to get time-based greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      // AppBar removed to allow for a custom branded header
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Branded Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_getGreeting()},",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    authProvider.user?.username ?? 'Movie Buff',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      // color: Theme.of(context).primaryColor, // Use your gold/brand color here
                    ),
                  ),
                ],
              ),
            ),

            // 2. Search Bar Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SearchBarWidget(token: authProvider.token!),
            ),

            // 3. Main Swiper Area
            Expanded(child: _buildBody(context, authProvider, movieProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AuthProvider auth,
    MovieProvider movieProv,
  ) {
    if ((movieProv.isLoading || movieProv.isAiLoading) &&
        movieProv.suggestionQueue.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(), // picks up gold from theme
      );
    }

    if (movieProv.suggestionQueue.isEmpty) {
      return _buildEmptyState(context, auth, movieProv);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CardSwiper(
        key: ValueKey(movieProv.suggestionQueue.length),
        cardsCount: movieProv.suggestionQueue.length,
        numberOfCardsDisplayed: movieProv.suggestionQueue.length < 3
            ? movieProv.suggestionQueue.length
            : 3,
        cardBuilder: (context, index, x, y) {
          final movie = movieProv.suggestionQueue[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movie: movie),
              ),
            ),
            child: MovieCard(movie: movie),
          );
        },
        onSwipe: (previousIndex, currentIndex, direction) {
          final currentMovie = movieProv.suggestionQueue[previousIndex];
          movieProv.recordInteraction(auth.token!, currentMovie, direction);
          return true;
        },
        padding: EdgeInsets.zero,
        isLoop: false,
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AuthProvider auth,
    MovieProvider movieProv,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_filter_outlined,
            size: 70,
            color: Color(0xFFE8C547), // was Colors.grey
          ),
          const SizedBox(height: 16),
          const Text(
            "No more movies left",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (auth.token != null) {
                movieProv.getAiRecommendations(auth.token!);
              }
            },
            // removed all style overrides — inherits gold button from theme
            child: const Text("Load More Suggestions"),
          ),
        ],
      ),
    );
  }
}
