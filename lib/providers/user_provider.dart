import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserProvider();

  // State variables
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Set current user
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser == null) {
        _error = 'No user loaded';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': name,
            'phone': phone,
          },
        ),
      );

      _currentUser = _currentUser!.copyWith(name: name, phone: phone);
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

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear state
  void clear() {
    _currentUser = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
