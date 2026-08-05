// API Response wrapper for all backend responses
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  // Factory constructor for successful response
  factory ApiResponse.success({
    required T data,
    String? message,
    int statusCode = 200,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  // Factory constructor for error response
  factory ApiResponse.error({
    required String error,
    int statusCode = 500,
    String? message,
  }) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
      message: message,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message, error: $error)';
  }
}

// Generic response model (matches backend structure)
class BaseApiResponse<T> {
  final T? data;
  final String? detail;
  final List<String>? errors;

  BaseApiResponse({
    this.data,
    this.detail,
    this.errors,
  });

  factory BaseApiResponse.fromJson(Map<String, dynamic> json, Function(Map<String, dynamic>) fromJsonT) {
    return BaseApiResponse(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      detail: json['detail'] as String?,
      errors: json['errors'] != null ? List<String>.from(json['errors'] as List) : null,
    );
  }
}

// Login request/response models
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final String tokenType;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}

// Register request/response models
class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String role;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': role,
    };
  }
}

class RegisterResponse {
  final int id;
  final String email;
  final String name;
  final String role;
  final String message;

  RegisterResponse({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'patient',
      message: json['message'] as String? ?? '',
    );
  }
}

// Exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
