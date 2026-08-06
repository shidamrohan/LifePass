import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service using SharedPreferences
class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _userPhoneKey = 'user_phone';
  static const String _isLoggedInKey = 'is_logged_in';

  late SharedPreferences _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== AUTH TOKEN ====================

  /// Save authentication token
  Future<bool> saveAuthToken(String token) async {
    return await _prefs.setString(_authTokenKey, token);
  }

  /// Get authentication token
  String? getAuthToken() {
    return _prefs.getString(_authTokenKey);
  }

  /// Clear authentication token
  Future<bool> clearAuthToken() async {
    return await _prefs.remove(_authTokenKey);
  }

  /// Check if user has valid token
  bool hasAuthToken() {
    return _prefs.containsKey(_authTokenKey);
  }

  // ==================== USER DATA ====================

  /// Save user information after login/register
  Future<bool> saveUserData({
    required int userId,
    required String email,
    required String name,
    required String phone,
    required String role,
  }) async {
    await _prefs.setInt(_userIdKey, userId);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userPhoneKey, phone);
    await _prefs.setString(_userRoleKey, role);
    return await _prefs.setBool(_isLoggedInKey, true);
  }

  /// Get user ID
  int? getUserId() {
    if (_prefs.containsKey(_userIdKey)) {
      return _prefs.getInt(_userIdKey);
    }
    return null;
  }

  /// Get user email
  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Get user name
  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  /// Get user phone
  String? getUserPhone() {
    return _prefs.getString(_userPhoneKey);
  }

  /// Get user role
  String? getUserRole() {
    return _prefs.getString(_userRoleKey);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ==================== LOGOUT ====================

  /// Clear all user data (logout)
  Future<bool> logout() async {
    await clearAuthToken();
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userPhoneKey);
    await _prefs.remove(_userRoleKey);
    return await _prefs.setBool(_isLoggedInKey, false);
  }

  // ==================== GENERIC ====================

  /// Save a string value
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save an integer value
  Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    if (_prefs.containsKey(key)) {
      return _prefs.getInt(key);
    }
    return null;
  }

  /// Save a boolean value
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get a boolean value
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Remove a value
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all data
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}

// Global storage service instance
final storageService = StorageService();
