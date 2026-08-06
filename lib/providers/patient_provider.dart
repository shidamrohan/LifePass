import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/api_service.dart';

class PatientProvider with ChangeNotifier {
  final ApiService _apiService;

  PatientProvider({required ApiService apiService}) : _apiService = apiService;

  // State variables
  PatientModel? _patientProfile;
  List<DiseaseModel> _diseases = [];
  List<AllergyModel> _allergies = [];
  List<MedicineModel> _medicines = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  PatientModel? get patientProfile => _patientProfile;
  List<DiseaseModel> get diseases => _diseases;
  List<AllergyModel> get allergies => _allergies;
  List<MedicineModel> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch patient profile
  Future<bool> fetchPatientProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<PatientModel>(
        '/patient/profile',
        fromJson: (json) => PatientModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        _patientProfile = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to fetch profile';
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

  /// Create or update patient profile
  Future<bool> savePatientProfile({
    required DateTime? dateOfBirth,
    required String? gender,
    required String? bloodGroup,
    required double? height,
    required double? weight,
    required String? emergencyContactName,
    required String? emergencyContactPhone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'dob': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'blood_group': bloodGroup,
        'height': height,
        'weight': weight,
        'emergency_contact': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
      };

      // Determine if POST (create) or PUT (update)
      final isUpdate = _patientProfile != null;
      final endpoint = '/patient/profile';

      final response = await (isUpdate
          ? _apiService.put<PatientModel>(
              endpoint,
              body: body,
              fromJson: (json) =>
                  PatientModel.fromJson(json as Map<String, dynamic>),
            )
          : _apiService.post<PatientModel>(
              endpoint,
              body: body,
              fromJson: (json) =>
                  PatientModel.fromJson(json as Map<String, dynamic>),
            ));

      if (response.success && response.data != null) {
        _patientProfile = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to save profile';
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

  // ==================== DISEASES ====================

  /// Fetch all diseases
  Future<bool> fetchDiseases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<List<DiseaseModel>>(
        '/patient/diseases',
        fromJson: (json) => ((json['diseases'] as List?) ?? [])
            .map((item) => DiseaseModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
      if (!response.success) throw Exception(response.error);
      _diseases = response.data ?? [];
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

  /// Add disease
  Future<bool> addDisease({
    required String name,
    required DateTime? diagnosedDate,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/patient/disease',
        body: {'disease_name': name, 'diagnosed_date': diagnosedDate?.toIso8601String()},
        fromJson: (json) => json as Map<String, dynamic>,
      );
      if (!response.success) throw Exception(response.error);
      await fetchDiseases();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove disease
  Future<bool> removeDisease(int diseaseId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>('/patient/disease/$diseaseId', fromJson: (json) => json as Map<String, dynamic>);
      if (!response.success) throw Exception(response.error);
      _diseases.removeWhere((d) => d.id == diseaseId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== ALLERGIES ====================

  /// Fetch all allergies
  Future<bool> fetchAllergies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<List<AllergyModel>>(
        '/patient/allergies',
        fromJson: (json) => ((json['allergies'] as List?) ?? [])
            .map((item) {
              final map = Map<String, dynamic>.from(item as Map);
              map['name'] ??= map['allergy'];
              return AllergyModel.fromJson(map);
            }).toList(),
      );
      if (!response.success) throw Exception(response.error);
      _allergies = response.data ?? [];
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

  /// Add allergy
  Future<bool> addAllergy({
    required String name,
    required String severity,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>('/patient/allergy', body: {'allergy': name, 'severity': severity}, fromJson: (json) => json as Map<String, dynamic>);
      if (!response.success) throw Exception(response.error);
      await fetchAllergies();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove allergy
  Future<bool> removeAllergy(int allergyId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>('/patient/allergy/$allergyId', fromJson: (json) => json as Map<String, dynamic>);
      if (!response.success) throw Exception(response.error);
      _allergies.removeWhere((a) => a.id == allergyId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== MEDICINES ====================

  /// Fetch all medicines
  Future<bool> fetchMedicines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<List<MedicineModel>>(
        '/patient/medicines',
        fromJson: (json) => ((json['medicines'] as List?) ?? [])
            .map((item) => MedicineModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
      if (!response.success) throw Exception(response.error);
      _medicines = response.data ?? [];
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

  /// Add medicine
  Future<bool> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>('/patient/medicine', body: {'medicine': name, 'dosage': dosage, 'frequency': frequency}, fromJson: (json) => json as Map<String, dynamic>);
      if (!response.success) throw Exception(response.error);
      await fetchMedicines();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove medicine
  Future<bool> removeMedicine(int medicineId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>('/patient/medicine/$medicineId', fromJson: (json) => json as Map<String, dynamic>);
      if (!response.success) throw Exception(response.error);
      _medicines.removeWhere((m) => m.id == medicineId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch all patient data at once (profile + diseases + allergies + medicines)
  Future<void> fetchPatientData() async {
    await Future.wait([
      fetchPatientProfile(),
      fetchDiseases(),
      fetchAllergies(),
      fetchMedicines(),
    ]);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all state
  void clear() {
    _patientProfile = null;
    _diseases = [];
    _allergies = [];
    _medicines = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
