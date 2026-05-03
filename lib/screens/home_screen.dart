// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/profile_view.dart';
import 'package:frontend/screens/suggestions_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const SuggestionsView(),
          ProfileView(isActive: _currentIndex == 1),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF0C0C12), // was 0xFF1E1E1E
        selectedItemColor: const Color(
          0xFFE8C547,
        ), // was Colors.deepPurpleAccent
        unselectedItemColor: Colors.white38,
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
