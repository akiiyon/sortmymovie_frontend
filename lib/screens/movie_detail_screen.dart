// lib/screens/movie_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../providers/auth_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  bool _isSaving = false;

  void _saveMovie(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    setState(() => _isSaving = true);

    try {
      await _movieService.saveMovie(token, widget.movie.id);
      if (mounted) {
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
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Deep dark background
      body: CustomScrollView(
        slivers: [
          // 1. The Collapsing App Bar with Hero Image
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
                  // The Poster Image
                  Hero(
                    tag: 'movie-poster-${widget.movie.id}',
                    child: widget.movie.posterUrl != null
                        ? Image.network(
                            widget.movie.posterUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey[900]),
                  ),
                  // Gradient Overlay for text readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Color(0xFF141414), // Fade into background color
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. The Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
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

                  // Metadata Row (Year • Duration • Rating)
                  Row(
                    children: [
                      if (widget.movie.releaseYear != null)
                        _buildMetaTag(widget.movie.releaseYear.toString()),
                      // Placeholder for rating if you add it later
                      const SizedBox(width: 10),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        "Popular", 
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Button (Save)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _saveMovie(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: _isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.add),
                      label: Text(
                        _isSaving ? "Saving..." : "Add to My List",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Genres Section
                  const Text("Genres", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.movie.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        backgroundColor: const Color(0xFF2B2B2B),
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  // Plot Overview
                  // Note: Since search results usually don't have the full plot, 
                  // we display a placeholder or existing data.
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "This is where the detailed plot summary would go. To get this text, your backend needs to return the 'overview' field from TMDB during the search or via a separate 'get details' API call.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[400],
                    ),
                  ),
                  
                  const SizedBox(height: 50), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for small text tags
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