import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../config/api_config.dart';
import '../models/api_models.dart';

class ApiService {
  late http.Client _httpClient;
  String? _authToken;

  ApiService() {
    _httpClient = http.Client();
  }

  /// Set authentication token (usually after login)
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token (on logout)
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get authorization headers
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token if available
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Make a GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    required T Function(dynamic json) fromJson,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = {..._getHeaders(), ...?additionalHeaders};

      final response = await _httpClient
          .get(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException catch (e) {
      return ApiResponse<T>.error(
        error: 'Network error: ${e.message}',
        statusCode: 0,
      );
    } on TimeoutException catch (_) {
      return ApiResponse<T>.error(
        error: 'Request timeout. Please try again.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        error: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Make a POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    required dynamic body,
    required T Function(dynamic json) fromJson,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = {..._getHeaders(), ...?additionalHeaders};

      final response = await _httpClient
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException catch (e) {
      return ApiResponse<T>.error(
        error: 'Network error: ${e.message}',
        statusCode: 0,
      );
    } on TimeoutException catch (_) {
      return ApiResponse<T>.error(
        error: 'Request timeout. Please try again.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        error: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Make a PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    required dynamic body,
    required T Function(dynamic json) fromJson,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = {..._getHeaders(), ...?additionalHeaders};

      final response = await _httpClient
          .put(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException catch (e) {
      return ApiResponse<T>.error(
        error: 'Network error: ${e.message}',
        statusCode: 0,
      );
    } on TimeoutException catch (_) {
      return ApiResponse<T>.error(
        error: 'Request timeout. Please try again.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        error: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Make a DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    required T Function(dynamic json) fromJson,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = {..._getHeaders(), ...?additionalHeaders};

      final response = await _httpClient
          .delete(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException catch (e) {
      return ApiResponse<T>.error(
        error: 'Network error: ${e.message}',
        statusCode: 0,
      );
    } on TimeoutException catch (_) {
      return ApiResponse<T>.error(
        error: 'Request timeout. Please try again.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        error: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Upload a report using multipart/form-data.
  Future<ApiResponse<Map<String, dynamic>>> uploadReport({
    required String path,
    required String reportType,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/reports/upload'));
      if (_authToken != null && _authToken!.isNotEmpty) request.headers['Authorization'] = 'Bearer $_authToken';
      request.fields['report_type'] = reportType;
      request.files.add(await http.MultipartFile.fromPath('file', path));
      final streamed = await request.send().timeout(ApiConfig.connectionTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse<Map<String, dynamic>>(response, (json) => json as Map<String, dynamic>);
    } on TimeoutException {
      return ApiResponse<Map<String, dynamic>>.error(error: 'Upload timed out. Please try again.', statusCode: 408);
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(error: 'Upload failed: $e', statusCode: 500);
    }
  }

  /// Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json) fromJson,
  ) {
    final statusCode = response.statusCode;

    try {
      final jsonBody = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        // Success response
        final data = fromJson(jsonBody);
        return ApiResponse<T>.success(
          data: data,
          statusCode: statusCode,
        );
      } else if (statusCode == 401) {
        // Unauthorized - token expired
        clearAuthToken();
        return ApiResponse<T>.error(
          error: jsonBody['detail'] ?? 'Unauthorized. Please login again.',
          statusCode: statusCode,
        );
      } else if (statusCode == 400) {
        // Bad request
        return ApiResponse<T>.error(
          error: jsonBody['detail'] ?? 'Bad request. Please check your input.',
          statusCode: statusCode,
        );
      } else if (statusCode == 404) {
        // Not found
        return ApiResponse<T>.error(
          error: jsonBody['detail'] ?? 'Resource not found.',
          statusCode: statusCode,
        );
      } else if (statusCode == 500) {
        // Server error
        return ApiResponse<T>.error(
          error: 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      } else {
        // Other error
        return ApiResponse<T>.error(
          error: jsonBody['detail'] ?? 'An error occurred.',
          statusCode: statusCode,
        );
      }
    } catch (e) {
      // JSON parse error
      return ApiResponse<T>.error(
        error: 'Failed to parse response: ${e.toString()}',
        statusCode: statusCode,
      );
    }
  }

  /// Test API connectivity
  Future<bool> testConnection() async {
    try {
      final response = await get<Map<String, dynamic>>(
        '/health',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }
}

// Global API service instance (singleton)
final apiService = ApiService();
