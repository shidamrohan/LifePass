class ApiConfig {
  // Backend API Base URL
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  // Or use your production URL:
  // static const String baseUrl = 'https://api.lifepass.com/api/v1';

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
