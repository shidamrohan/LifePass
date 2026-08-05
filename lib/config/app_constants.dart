class AppConstants {
  // App Info
  static const String appName = 'LifePass';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-Powered Emergency Health Identity Platform';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String patientProfileKey = 'patient_profile';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userIdKey = 'user_id';

  // Role Constants
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleAdmin = 'admin';

  // Blood Groups
  static const List<String> bloodGroups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

  // Severity Levels
  static const List<String> allergySeverity = ['Mild', 'Moderate', 'Severe'];

  // Report Types
  static const List<String> reportTypes = ['Prescription', 'Lab Report', 'Discharge Summary'];
  static const String reportTypePrescription = 'prescription';
  static const String reportTypeLabReport = 'lab_report';
  static const String reportTypeDischargeSmary = 'discharge_summary';

  // Gender Options
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];

  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorUnauthorized = 'Invalid credentials. Please try again.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorGeneral = 'An error occurred. Please try again.';
  static const String errorValidation = 'Please fill in all required fields.';

  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successRegister = 'Registration successful!';
  static const String successProfileCreated = 'Profile created successfully!';
  static const String successProfileUpdated = 'Profile updated successfully!';
  static const String successLogout = 'Logged out successfully!';
}
