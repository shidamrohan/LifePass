import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider({
    required StorageService storageService,
  }) : _storageService = storageService;

  // State variables
  bool _isLoading = false;
  String? _error;
  UserModel? _user;
  bool _isLoggedIn = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  /// Initialize auth state
  Future<void> initialize() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _isLoggedIn = true;
        _mapUserFromSupabase(session.user);
        notificationService.listenForEmergencyAccess();
      } else {
        _isLoggedIn = false;
      }
    } catch (e) {
      print('Error initializing auth: $e');
      _isLoggedIn = false;
    }
    
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _isLoggedIn = true;
        _mapUserFromSupabase(session.user);
        notificationService.listenForEmergencyAccess();
      } else {
        _isLoggedIn = false;
        _user = null;
        notificationService.stopListening();
      }
      notifyListeners();
    });
    
    notifyListeners();
  }

  void _mapUserFromSupabase(User user) {
    final metadata = user.userMetadata ?? {};
    _user = UserModel(
      id: user.id,
      email: user.email ?? '',
      name: metadata['name'] ?? user.email?.split('@')[0] ?? '',
      phone: metadata['phone'] ?? '',
      role: metadata['role'] ?? 'patient',
      isActive: true,
      createdAt: DateTime.now(),
    );
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
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'role': role,
        },
      );

      if (response.user != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
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
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _mapUserFromSupabase(response.user!);

        if (_user!.role != 'patient') {
          await _supabase.auth.signOut();
          _user = null;
          _isLoggedIn = false;
          _error = 'Hospital staff must sign in through the Hospital Portal.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed';
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
      await _supabase.auth.signOut();
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
      await _supabase.auth.resetPasswordForEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
