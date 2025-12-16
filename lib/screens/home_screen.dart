// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import '../services/movie_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ensure initial suggestions are loaded once on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      if (authProvider.token != null && !movieProvider.isLoading) {
        movieProvider.loadInitialSuggestions(authProvider.token!);
      }
    });

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MovieProvider())],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movie Suggestions'),
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
        body: Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            if (movieProvider.isLoading &&
                movieProvider.suggestionQueue.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (movieProvider.suggestionQueue.isEmpty) {
              return const Center(
                child: Text(
                  'No more suggestions! Swiping will fetch more...',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CardSwiper(
                      // 1. Use cardsCount instead of passing the entire 'cards' list
                      cardsCount: movieProvider.suggestionQueue.length,

                      // 2. Use cardBuilder to build the widget dynamically by index
                      cardBuilder:
                          (
                            context,
                            index,
                            percentThresholdX,
                            percentThresholdY,
                          ) {
                            final movie = movieProvider.suggestionQueue[index];
                            return MovieCard(movie: movie);
                          },

                      // 3. The onSwipe callback parameter is correct
                      onSwipe:
                          (
                            int previousIndex,
                            int? currentIndex,
                            CardSwiperDirection direction,
                          ) {
                            final currentMovie =
                                movieProvider.suggestionQueue[previousIndex];
                            // User swiped, remove the top card
                            // Note: Use listen: false to call methods on the provider
                            debugPrint(
                              'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
                            );
                            Provider.of<MovieProvider>(
                              context,
                              listen: false,
                            ).recordInteraction(
                              authProvider.token!,
                              currentMovie,
                              direction,
                            );
                            return true;
                          },

                      padding: const EdgeInsets.all(0),
                      isLoop: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (movieProvider.suggestionQueue.isNotEmpty) {
                        // Simulate a Skip/Dislike interaction when 'Next' is pressed
                        final currentMovie = movieProvider.suggestionQueue[0];
                        Provider.of<MovieProvider>(
                          context,
                          listen: false,
                        ).recordInteraction(
                          authProvider.token!,
                          currentMovie,
                          CardSwiperDirection
                              .left, // Treat button press as a skip/dislike
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_ios),
                    label: const Text('Next Suggestion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- Component: Movie Card ---

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: movie.posterUrl != null
                  ? Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          ),
                    )
                  : const Center(child: Text('No Poster Available')),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.releaseYear ?? 'N/A'} | ${movie.genres.join(', ')}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Component: Search Bar ---

class SearchBarWidget extends StatefulWidget {
  final String token;
  const SearchBarWidget({super.key, required this.token});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final MovieService _movieService = MovieService();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          hintText: "Search movies to save...",
          padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          leading: const Icon(Icons.search),
        );
      },
      suggestionsBuilder:
          (BuildContext context, SearchController controller) async {
            if (controller.text.isEmpty) {
              return const <Widget>[];
            }

            // Debounce or add a minimum length check in a real app
            final results = await _movieService.searchMovies(controller.text);

            return results.map((movie) {
              return ListTile(
                leading: movie.posterUrl != null
                    ? Image.network(
                        movie.posterUrl!,
                        width: 40,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.movie),
                title: Text(movie.title),
                subtitle: Text(movie.genres.join(', ')),
                trailing: _isSearching
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () async {
                          setState(() {
                            _isSearching =
                                true; // Use this state to show loading on button
                          });
                          try {
                            await _movieService.saveMovie(
                              widget.token,
                              movie.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${movie.title} saved!')),
                            );
                            controller.closeView(null); // Close the search view
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            setState(() {
                              _isSearching = false;
                            });
                          }
                        },
                      ),
              );
            }).toList();
          },
    );
  }
}
