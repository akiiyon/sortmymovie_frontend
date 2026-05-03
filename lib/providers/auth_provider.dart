// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  User? _user;
  bool _isLoading = false;

  String? get token => _token;
  User? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  bool _isFirstLaunch = false;
  bool get isFirstLaunch => _isFirstLaunch;

  // Future<void> autoLogin() async {
  //   _isLoading = true;
  //   _token = await _storage.read(key: 'jwt_token');

  //   if (_token != null) {
  //     // Fetch fresh profile data using the stored token
  //     try {
  //       _user = await _authService.fetchCurrentUser(_token!);
  //     } catch (e) {
  //       // If token fails to fetch profile (e.g., token expired), log out.
  //       await logout();
  //     }
  //   }
  //   print(_user);
  //   _isLoading = false;
  //   notifyListeners();
  // }

  // In AuthProvider, update autoLogin():
Future<void> autoLogin() async {
  _isLoading = true;
  notifyListeners();

  _token = await _storage.read(key: 'jwt_token');
  final hasLaunchedBefore = await _storage.read(key: 'has_launched');

  _isFirstLaunch = hasLaunchedBefore == null; // null means never launched

  if (_isFirstLaunch) {
    await _storage.write(key: 'has_launched', value: 'true');
  }

  if (_token != null) {
    try {
      _user = await _authService.fetchCurrentUser(_token!);
    } catch (e) {
      await logout();
    }
  }

  _isLoading = false;
  notifyListeners();
}

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.getLoginToken(email, password);
      print("GOT TOKEN: $token");
      _token = token;

      //using token to fetch the profile
      _user = await _authService.fetchCurrentUser(token!);

      await _storage.write(key: 'jwt_token', value: token);
    } catch (e) {
      _token = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //register
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.register(username, email, password);
      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authService.logout(_token!);
      }
    } catch (e) {
      // Even if the backend call fails, we still clear local state
      debugPrint('Logout error: $e');
    } finally {
      _token = null;
      _user = null; // ← clear user too
      await _storage.delete(key: 'jwt_token');
      notifyListeners();
    }
  }
}
