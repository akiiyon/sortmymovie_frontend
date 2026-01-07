import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/models/movie.dart';
import 'package:frontend/screens/movie_detail_screen.dart';
import 'package:frontend/services/movie_service.dart';
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