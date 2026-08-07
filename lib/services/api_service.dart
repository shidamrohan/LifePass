import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  ApiResponse({required this.success, this.data, this.error});
}

class ApiService {
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api/v1';

  // Helper to get patient ID from supabase auth
  String get _patientId => Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<ApiResponse<T>> get<T>(String endpoint, {required T Function(dynamic) fromJson}) async {
    try {
      // In old code, patient ID was likely sent or hardcoded. We can just append it if needed,
      // but let's check the endpoint. 
      // If the UI doesn't append it, we append it here:
      String url = '$_baseUrl$endpoint';
      if (endpoint == '/qr/generate' || endpoint == '/reports/history' || endpoint == '/reports/summary') {
        url = '$url/$_patientId';
      }

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return ApiResponse(success: true, data: fromJson(decoded));
      } else {
        return ApiResponse(success: false, error: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadReport({required String path, required String reportType}) async {
    try {
      final file = File(path);
      final fileName = '${_patientId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload to Supabase Storage (bucket 'reports')
      await Supabase.instance.client.storage
          .from('reports')
          .upload(fileName, file);
          
      // Get public URL
      final fileUrl = Supabase.instance.client.storage
          .from('reports')
          .getPublicUrl(fileName);
          
      // Now insert record into database so Python worker can process it
      await Supabase.instance.client.from('medical_reports').insert({
        'patient_id': _patientId,
        'report_type': reportType,
        'file_url': fileUrl,
        'status': 'pending',
      });
      
      return ApiResponse(success: true, data: {'message': 'Report uploaded. Processing in background.'});
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}

final apiService = ApiService();
