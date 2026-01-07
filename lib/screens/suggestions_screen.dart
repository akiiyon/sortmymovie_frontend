// lib/screens/suggestions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import 'movie_detail_screen.dart';
import '../widgets/movie_card.dart';
import '../widgets/searchbar_widget.dart';

// ... imports remain the same

class SuggestionsView extends StatelessWidget {
  const SuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // ... build method remains the same
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Movie Suggestions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SearchBarWidget(token: authProvider.token!),
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildBody(context, authProvider, movieProvider),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (movieProv.suggestionQueue.isEmpty) {
      print("kuch bhi");
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

        // ▼▼▼▼▼ UPDATED LOGIC HERE ▼▼▼▼▼
        onSwipe: (previousIndex, currentIndex, direction) {
          final currentMovie = movieProv.suggestionQueue[previousIndex];

          // Logic: recordInteraction will now handle both Likes and Dislikes in the DB
          movieProv.recordInteraction(auth.token!, currentMovie, direction);

          return true;
        },

        // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
        padding: EdgeInsets.zero,
        isLoop: false,
      ),
    );
  }

  // ... _buildEmptyState remains the same
  Widget _buildEmptyState(
    BuildContext context,
    AuthProvider auth,
    MovieProvider movieProv,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_filter_outlined, size: 70, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No more movies left",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              print("pressed");
              if (auth.token != null) {
                // Now, when we call this, the provider should include the rejected IDs
                print(auth.token);
                movieProv.getAiRecommendations(auth.token!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Load More Suggestions",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
