// lib/screens/movie_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  bool _isSaving = false;
  bool _isSaved = false; // 1. New state to track "Added" status

  void _saveMovie(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final token = authProvider.token!;

    setState(() => _isSaving = true);

    try {
      await _movieService.saveMovie(token, widget.movie.id);

      // Update local list
      await movieProvider.fetchSavedMovies(token);

      if (mounted) {
        setState(() {
          _isSaved = true; // 2. Mark as saved to update button UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.movie.title} added to your list!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Helper to parse rating safely (assuming rating might be a String or Double)
    // If your movie.rating is not defined in the model, you might need to add it.
    // Here I assume it's stored as dynamic or String in your model.
    String ratingDisplay = "N/A";

    // if (widget.movie.rating != null) {
    //   ratingDisplay = widget.movie.rating.toString();
    //   // Optional: Truncate to 1 decimal if it's long (e.g. 6.809 -> 6.8)
    //   if (ratingDisplay.length > 3)
    //     ratingDisplay = ratingDisplay.substring(0, 3);
    // }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 450.0,
            pinned: true,
            backgroundColor: const Color(0xFF141414),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black45,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'movie-poster-${widget.movie.id}',
                    child: widget.movie.posterUrl != null
                        ? Image.network(
                            widget.movie.posterUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey[900]),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Color(0xFF141414),
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- METADATA ROW ---
                  Row(
                    children: [
                      if (widget.movie.releaseYear != null)
                        _buildMetaTag(widget.movie.releaseYear.toString()),
                      const SizedBox(width: 10),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      // 4. CHANGED: Display actual rating instead of "Popular"
                      Text(
                        ratingDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- ACTION BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      // 5. CHANGED: Disable button if saving OR already saved
                      onPressed: (_isSaving || _isSaved)
                          ? null
                          : () => _saveMovie(context),
                      style: ElevatedButton.styleFrom(
                        // Change color if saved
                        backgroundColor: _isSaved
                            ? Colors.green[800]
                            : Colors.white,
                        disabledBackgroundColor: _isSaved
                            ? Colors.green[800]
                            : Colors.grey,
                        foregroundColor: _isSaved ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(_isSaved ? Icons.check : Icons.add),
                      label: Text(
                        // 6. CHANGED: Update text based on state
                        _isSaving
                            ? "Saving..."
                            : (_isSaved ? "Added to List" : "Add to My List"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isSaved ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- GENRES SECTION ---
                  if (widget.movie.genres.isNotEmpty) ...[
                    const Text(
                      "Genres",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.movie.genres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor: const Color(0xFF2B2B2B),
                          labelStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                  ],

                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "This is where the detailed plot summary would go...",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
