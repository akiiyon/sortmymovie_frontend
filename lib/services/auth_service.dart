// lib/services/auth_service.dart
import 'dart:convert';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Use 10.0.2.2 for Android emulator to talk to localhost:3000
  // Use localhost:3000 for iOS simulator or web
  final String baseUrl = '${BACKEND_BASE_URL}/auth'; 

  Future<String?> getLoginToken(String email, String password) async {
    print('Login email: $email, password: $password');
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
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
}