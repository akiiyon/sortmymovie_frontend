// lib/screens/profile_view.dart
import 'package:flutter/material.dart';

import 'package:frontend/screens/saved_movies_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';

class ProfileView extends StatefulWidget {
  final bool isActive;
  const ProfileView({super.key, required this.isActive});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const _bg = Color(0xFF0C0C12);
  static const _gold = Color(0xFFE8C547);
  static const _surface = Color(0xFF1A1A24);
  static const _border = Color(0xFF2A2A38);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(covariant ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    if (authProvider.token != null) {
      movieProvider.fetchSavedMovies(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: _bg, // was Colors.black
      appBar: AppBar(
        title: Text("${authProvider.user?.username ?? 'Your'} 's Watchlist"),
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
                color: _surface, // was Color(0xFF2C2C2C)
                borderRadius: BorderRadius.circular(8), // was 16
                border: Border.all(
                  color: _border,
                ), // added to match login card feel
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: _gold, // was Colors.deepPurpleAccent
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: _bg,
                    ), // icon color was Colors.white
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.username ?? "User",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user?.email ?? "email@example.com",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white38,
                    ), // was white54
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Change Password Clicked"),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: _gold,
                        ), // was Colors.deepPurple
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // was default
                        ),
                      ),
                      child: const Text("Change Password"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        authProvider.logout();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: _gold,
                        ), // was Colors.deepPurple
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // was default
                        ),
                      ),
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "My Saved List",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // 2. Saved Movies Grid
            if (movieProvider.isSavedMoviesLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: _gold, // was default
                  ),
                ),
              )
            else if (movieProvider.savedMovies.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    "No movies saved yet. Start swiping!",
                    style: TextStyle(color: Colors.white38), // was Colors.grey
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SavedMovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8), // was 12
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              movie.posterUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: _surface, // was Colors.grey[800]
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.white38, // was white54
                                ),
                              ),
                            ),
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
