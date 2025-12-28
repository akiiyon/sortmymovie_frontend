// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import '../services/movie_service.dart';
import 'dart:async';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // List of screens for the bottom navigation
  final List<Widget> _screens = [const SuggestionsView(), const ProfileView()];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ensure initial suggestions are loaded once on build
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    //   if (authProvider.token != null && !movieProvider.isLoading) {
    //     movieProvider.loadInitialSuggestions(authProvider.token!);
    //   }
    // });

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Movie Suggestions'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: () => authProvider.logout(),
      //     ),
      //   ],
      //   // bottom: PreferredSize(
      //   //   preferredSize: const Size.fromHeight(60.0),
      //   //   child: Padding(
      //   //     padding: const EdgeInsets.symmetric(
      //   //       horizontal: 16.0,
      //   //       vertical: 8.0,
      //   //     ),
      //   //     child: SearchBarWidget(token: authProvider.token!),
      //   //   ),
      //   // ),
      // ),
      // body: Consumer<MovieProvider>(
      //   builder: (context, movieProvider, child) {
      //     if (movieProvider.isLoading &&
      //         movieProvider.suggestionQueue.isEmpty) {
      //       return const Center(child: CircularProgressIndicator());
      //     }

      //     if (movieProvider.suggestionQueue.isEmpty) {
      //       return const Center(
      //         child: Text(
      //           'No more suggestions! Swiping will fetch more...',
      //           style: TextStyle(color: Colors.white70),
      //         ),
      //       );
      //     }

      //     return Column(
      //       children: [
      //         Expanded(
      //           child: Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: CardSwiper(
      //               // 1. Use cardsCount instead of passing the entire 'cards' list
      //               cardsCount: movieProvider.suggestionQueue.length,

      //               // 2. Use cardBuilder to build the widget dynamically by index
      //               cardBuilder:
      //                   (
      //                     context,
      //                     index,
      //                     percentThresholdX,
      //                     percentThresholdY,
      //                   ) {
      //                     final movie = movieProvider.suggestionQueue[index];
      //                     return MovieCard(movie: movie);
      //                   },

      //               // 3. The onSwipe callback parameter is correct
      //               onSwipe:
      //                   (
      //                     int previousIndex,
      //                     int? currentIndex,
      //                     CardSwiperDirection direction,
      //                   ) {
      //                     final currentMovie =
      //                         movieProvider.suggestionQueue[previousIndex];
      //                     // User swiped, remove the top card
      //                     // Note: Use listen: false to call methods on the provider
      //                     debugPrint(
      //                       'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
      //                     );
      //                     Provider.of<MovieProvider>(
      //                       context,
      //                       listen: false,
      //                     ).recordInteraction(
      //                       authProvider.token!,
      //                       currentMovie,
      //                       direction,
      //                     );
      //                     return true;
      //                   },

      //               padding: const EdgeInsets.all(0),
      //               isLoop: false,
      //             ),
      //           ),
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.only(bottom: 30.0),
      //           child: ElevatedButton.icon(
      //             onPressed: () {
      //               if (movieProvider.suggestionQueue.isNotEmpty) {
      //                 // Simulate a Skip/Dislike interaction when 'Next' is pressed
      //                 final currentMovie = movieProvider.suggestionQueue[0];
      //                 Provider.of<MovieProvider>(
      //                   context,
      //                   listen: false,
      //                 ).recordInteraction(
      //                   authProvider.token!,
      //                   currentMovie,
      //                   CardSwiperDirection
      //                       .left, // Treat button press as a skip/dislike
      //                 );
      //               }
      //             },
      //             icon: const Icon(Icons.arrow_forward_ios),
      //             label: const Text('Next Suggestion'),
      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: Colors.deepPurple,
      //               padding: const EdgeInsets.symmetric(
      //                 horizontal: 30,
      //                 vertical: 15,
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     );
      //   },
      // ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter),
            label: 'Suggestions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// lib/screens/home_screen.dart

class SuggestionsView extends StatelessWidget {
  const SuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to the provider to rebuild the UI whenever the list changes
    final movieProvider = Provider.of<MovieProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(title: const Text('Movie Suggestions'), elevation: 0),
      body: Container(
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
    // 1. Show loading spinner if AI is thinking or initial cards are loading
    if ((movieProv.isLoading || movieProv.isAiLoading) &&
        movieProv.suggestionQueue.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. If the queue is empty and NOT loading, show the Load More button
    if (movieProv.suggestionQueue.isEmpty) {
      return _buildEmptyState(context, auth, movieProv);
    }

    // 3. If there are cards, show the Swiper
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CardSwiper(
        cardsCount: movieProv.suggestionQueue.length,
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
        onSwipe: (prev, curr, direction) {
          final currentMovie = movieProv.suggestionQueue[prev];
          // Record the interaction in the background
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
          const Icon(Icons.movie_filter_outlined, size: 70, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No more movies left",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (auth.token != null) {
                // Trigger the AI recommendation logic
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

// ==========================================
// TAB 2: PROFILE VIEW (New UI)
// ==========================================

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  void initState() {
    super.initState();
    // Use WidgetsBinding to call the fetch logic after the initial build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    if (authProvider.token != null) {
      // Fetch the saved movies when the profile screen is loaded
      movieProvider.fetchSavedMovies(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: In a real app, you would get this list from movieProvider.savedMovies
    // For now, I'm creating a dummy list to visualize the grid.

    // Listen to both providers for state changes
    final authProvider = Provider.of<AuthProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);

    final user = authProvider.user;

    // final List<Movie> dummySavedMovies = List.generate(
    //   6,
    //   (index) => Movie(
    //     id: index,
    //     title: "Saved Movie ${index + 1}",
    //     genres: ["Action", "Sci-Fi"],
    //     posterUrl: "https://via.placeholder.com/150",
    //     releaseYear: 2023,
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Account Info Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurpleAccent,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.username ?? "John Doe", // Username
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user?.email ?? "john.doe@example.com", // Email
                    style: TextStyle(fontSize: 16, color: Colors.white54),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement change password logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Change Password Clicked"),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Change Password"),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "My Saved List",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // 2. Saved Movies Grid
            if (movieProvider.isSavedMoviesLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (movieProvider.savedMovies.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    "No movies saved yet. Start swiping!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: movieProvider.savedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = movieProvider.savedMovies[index];
                    return GestureDetector(
                      onTap: () {
                        // TODO: Implement navigation to MovieDetailScreen here if desired
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              movie.posterUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            // Gradient and Title Overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black87,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 30),
          ],
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

  Timer? _debounce;
  List<Movie> _searchResults = [];

  @override
  void dispose() {
    _debounce
        ?.cancel(); // 3. IMPORTANT: Cancel the timer when the widget is disposed
    super.dispose();
  }

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

            _debounce?.cancel();

            final Completer<List<Widget>> completer = Completer();

            _debounce = Timer(const Duration(milliseconds: 500), () async {
              try {
                // 5. This code only runs if the timer isn't cancelled (user stopped typing)
                final results = await _movieService.searchMovies(
                  controller.text,
                );

                final widgets = results.map((movie) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(movie: movie),
                        ),
                      );
                    },
                    leading: movie.posterUrl != null
                        ? Image.network(
                            movie.posterUrl!,
                            width: 40,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.movie),
                    title: Text(movie.title),
                    subtitle: Text(movie.genres.join(', ')),
                    // Note: Keeping your existing trailing logic
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () async {
                        // ... Your existing save logic ...
                      },
                    ),
                  );
                }).toList();

                // 6. Complete the Future with the widgets
                if (!completer.isCompleted) {
                  completer.complete(widgets);
                }
              } catch (e) {
                // Handle errors gracefully inside the search view
                if (!completer.isCompleted) {
                  completer.completeError(e);
                }
              }
            });

            return completer.future;
          },
    );
  }
}
