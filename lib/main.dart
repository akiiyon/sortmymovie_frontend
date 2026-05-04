// lib/main.dart
import 'package:flutter/material.dart';
import 'package:frontend/providers/movie_provider.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..autoLogin(),
        ),
        ChangeNotifierProvider(
          create: (context) => MovieProvider(),
        ), // Add MovieProvider here
      ],
      child: const MovieSuggestionApp(),
    ),
  );
}

class MovieSuggestionApp extends StatelessWidget {
  const MovieSuggestionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Suggestion App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0C12),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0C0C12)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2A2A38)),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isAuthenticated) return const HomeScreen();
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return auth.isFirstLaunch
              ? const RegisterScreen()
              : const LoginScreen();
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
