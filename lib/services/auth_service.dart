// lib/services/auth_service.dart
import 'dart:convert';
import 'package:frontend/constants.dart';
import 'package:frontend/models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Use 10.0.2.2 for Android emulator to talk to localhost:3000
  // Use localhost:3000 for iOS simulator or web
  final String baseUrl = '${BACKEND_BASE_URL}/auth';

  Future<String?> getLoginToken(String email, String password) async {
    print('Login email: $email, password: $password');
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['token']; // Return the JWT token
    } else {
      // Throw the error message from the backend
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Login failed');
    }
  }

  // TODO: Implement register here

  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Registration failed');
    }
  }

  //get user details
  Future<User> fetchCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userInfo'), // getuser details route
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // If the token is invalid or expired, this is where we catch it.
      throw Exception('Failed to fetch user profile.');
    }
  }
  Future<void> logout(String token) async {
  final response = await http.post(
    Uri.parse('$baseUrl/logout'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['error'] ?? 'Logout failed');
  }
}
}
