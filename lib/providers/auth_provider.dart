import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthProvider({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  // State variables
  bool _isLoading = false;
  String? _error;
  String? _authToken;
  UserModel? _user;
  bool _isLoggedIn = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get authToken => _authToken;
  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  /// Initialize auth state (check if user is logged in)
  Future<void> initialize() async {
    try {
      // Check if token exists in storage
      final token = _storageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        _apiService.setAuthToken(token);
        _isLoggedIn = true;
        
        // Load user data from storage
        _loadUserFromStorage();
      }
    } catch (e) {
      print('Error initializing auth: $e');
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  /// Load user data from storage
  void _loadUserFromStorage() {
    final userId = _storageService.getUserId();
    final email = _storageService.getUserEmail();
    final name = _storageService.getUserName();
    final phone = _storageService.getUserPhone();
    final role = _storageService.getUserRole();

    if (userId != null && email != null && name != null) {
      _user = UserModel(
        id: userId,
        email: email,
        name: name,
        phone: phone ?? '',
        role: role ?? 'patient',
        isActive: true,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );

      final response = await _apiService.post<RegisterResponse>(
        '/auth/register',
        body: registerRequest.toJson(),
        fromJson: (json) => RegisterResponse.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loginRequest = LoginRequest(email: email, password: password);

      final response = await _apiService.post<LoginResponse>(
        '/auth/login',
        body: loginRequest.toJson(),
        fromJson: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        // Save token
        _authToken = response.data!.accessToken;
        await _storageService.saveAuthToken(_authToken!);
        _apiService.setAuthToken(_authToken!);

        // TODO: Fetch user details after login
        // For now, we'll create a basic user object
        _user = UserModel(
          id: 0,
          email: email,
          name: email.split('@')[0],
          phone: '',
          role: 'patient',
          isActive: true,
          createdAt: DateTime.now(),
        );

        // Save user data to storage
        await _storageService.saveUserData(
          userId: _user!.id,
          email: email,
          name: _user!.name,
          phone: '',
          role: 'patient',
        );

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear token from API service
      _apiService.clearAuthToken();

      // Clear all data from storage
      await _storageService.logout();

      // Reset state
      _authToken = null;
      _user = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Forgot password
  Future<bool> forgotPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        body: {'email': email},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to send reset email';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
