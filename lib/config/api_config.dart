import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

enum Environment { development, staging, production }

class ApiConfig {
  // ===== CHANGE THIS TO SWITCH ENVIRONMENTS =====
  static const Environment environment = Environment.development;
  
  // Development: Your machine IP (change to your actual IP for physical devices)
  static const String devMachineIp = '192.168.0.106'; // Change this to your machine's IP
  
  // Get host IP based on platform (Android emulator needs 10.0.2.2, Web/Desktop uses localhost)
  static String get _devHost {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  // Backend API Base URL - Auto-selects based on environment
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://$_devHost:8000/api/v1';
      
      case Environment.staging:
        return 'http://$devMachineIp:8000/api/v1';
      
      case Environment.production:
        return 'https://api.lifepass.com/api/v1';
    }
  }
  
  // Helper method to test connection
  static String getConnectionInfo() {
    return '''
    Environment: ${environment.name}
    Base URL: $baseUrl
    
    For Physical Device on same WiFi:
      1. Find your machine's IP: ipconfig (Windows)
      2. Replace devMachineIp = '$devMachineIp' with your actual IP
      3. Change environment to staging
      4. Rebuild app
    ''';
  }

  // API Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authForgotPassword = '/auth/forgot-password';

  // Patient Endpoints
  static const String patientProfile = '/patient/profile';
  static const String patientDiseases = '/patient/diseases';
  static const String patientDisease = '/patient/disease';
  static const String patientAllergies = '/patient/allergies';
  static const String patientAllergy = '/patient/allergy';
  static const String patientMedicines = '/patient/medicines';
  static const String patientMedicine = '/patient/medicine';

  // Reports Endpoints
  static const String reportsUpload = '/reports/upload';
  static const String reportsHistory = '/reports/history';
  static const String reportsSummary = '/reports/summary';

  // Emergency Endpoints
  static const String emergencyProfile = '/emergency/profile';
  static const String emergencyRegenerate = '/emergency/regenerate';

  // QR Endpoints
  static const String qrGenerate = '/qr/generate';
  static const String qrScan = '/qr/scan';

  // Doctor Endpoints
  static const String doctorPatient = '/doctor/patient';
  static const String doctorTreatment = '/doctor/treatment';
  static const String doctorAuditLogs = '/doctor/audit-logs';
  static const String doctorMyActivity = '/doctor/my-activity';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
