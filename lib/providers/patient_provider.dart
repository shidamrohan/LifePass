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
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'blood_group': bloodGroup,
        'height': height,
        'weight': weight,
        'emergency_contact_name': emergencyContactName,
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
      // TODO: Implement API call
      // For now, return empty list
      _diseases = [];
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
      // TODO: Make API call
      // final body = {
      //   'name': name,
      //   'diagnosed_date': diagnosedDate?.toIso8601String(),
      // };
      // const response = await _apiService.post<DiseaseModel>(
      //   '/patient/diseases',
      //   body: body,
      //   fromJson: (json) => DiseaseModel.fromJson(json),
      // );

      // if (response.success && response.data != null) {
      //   _diseases.add(response.data!);
      //   notifyListeners();
      //   return true;
      // }

      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove disease
  Future<bool> removeDisease(int diseaseId) async {
    try {
      // TODO: Make API call
      // final response = await _apiService.delete<Map<String, dynamic>>(
      //   '/patient/disease/$diseaseId',
      //   fromJson: (json) => json as Map<String, dynamic>,
      // );

      // if (response.success) {
      //   _diseases.removeWhere((d) => d.id == diseaseId);
      //   notifyListeners();
      //   return true;
      // }

      return false;
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
      // TODO: Implement API call
      // For now, return empty list
      _allergies = [];
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
      // TODO: Make API call
      // final body = {
      //   'name': name,
      //   'severity': severity,
      // };
      // final response = await _apiService.post<AllergyModel>(
      //   '/patient/allergies',
      //   body: body,
      //   fromJson: (json) => AllergyModel.fromJson(json),
      // );

      // if (response.success && response.data != null) {
      //   _allergies.add(response.data!);
      //   notifyListeners();
      //   return true;
      // }

      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove allergy
  Future<bool> removeAllergy(int allergyId) async {
    try {
      // TODO: Make API call
      // final response = await _apiService.delete<Map<String, dynamic>>(
      //   '/patient/allergy/$allergyId',
      //   fromJson: (json) => json as Map<String, dynamic>,
      // );

      // if (response.success) {
      //   _allergies.removeWhere((a) => a.id == allergyId);
      //   notifyListeners();
      //   return true;
      // }

      return false;
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
      // TODO: Implement API call
      // For now, return empty list
      _medicines = [];
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
      // TODO: Make API call
      // final body = {
      //   'name': name,
      //   'dosage': dosage,
      //   'frequency': frequency,
      // };
      // final response = await _apiService.post<MedicineModel>(
      //   '/patient/medicines',
      //   body: body,
      //   fromJson: (json) => MedicineModel.fromJson(json),
      // );

      // if (response.success && response.data != null) {
      //   _medicines.add(response.data!);
      //   notifyListeners();
      //   return true;
      // }

      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove medicine
  Future<bool> removeMedicine(int medicineId) async {
    try {
      // TODO: Make API call
      // final response = await _apiService.delete<Map<String, dynamic>>(
      //   '/patient/medicine/$medicineId',
      //   fromJson: (json) => json as Map<String, dynamic>,
      // );

      // if (response.success) {
      //   _medicines.removeWhere((m) => m.id == medicineId);
      //   notifyListeners();
      //   return true;
      // }

      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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
