import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  UserProvider({required ApiService apiService});

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

      // TODO: Make API call to update user
      // final response = await _apiService.put<UserModel>(
      //   '/user/profile',
      //   body: {'name': name, 'phone': phone},
      //   fromJson: (json) => UserModel.fromJson(json),
      // );

      // if (response.success && response.data != null) {
      //   _currentUser = response.data;
      //   _isLoading = false;
      //   notifyListeners();
      //   return true;
      // }

      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
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
      // TODO: Make API call to change password
      // final response = await _apiService.post<Map<String, dynamic>>(
      //   '/user/change-password',
      //   body: {'old_password': oldPassword, 'new_password': newPassword},
      //   fromJson: (json) => json as Map<String, dynamic>,
      // );

      // if (response.success) {
      //   _isLoading = false;
      //   notifyListeners();
      //   return true;
      // }

      _error = 'Failed to change password';
      _isLoading = false;
      notifyListeners();
      return false;
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
