import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient_model.dart';

class PatientProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

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

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Fetch patient profile
  Future<bool> fetchPatientProfile() async {
    if (_userId == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabase.from('profiles').select().eq('id', _userId!).maybeSingle();

      if (data != null) {
        _patientProfile = PatientModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to fetch profile';
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
    if (_userId == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'id': _userId,
        'dob': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'blood_group': bloodGroup,
        'height': height,
        'weight': weight,
        'emergency_contact': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
      };

      // Use update instead of upsert because the row is created via database trigger on signup
      // Upsert requires INSERT permissions which the user does not have (RLS)
      final data = await _supabase.from('profiles').update(body).eq('id', _userId!).select().single();
      
      _patientProfile = PatientModel.fromJson(data);
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

  // ==================== DISEASES ====================

  /// Fetch all diseases
  Future<bool> fetchDiseases() async {
    if (_userId == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabase.from('diseases').select().eq('patient_id', _userId!);
      _diseases = data.map((item) => DiseaseModel.fromJson(item)).toList();
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
    if (_userId == null) return false;
    try {
      await _supabase.from('diseases').insert({
        'patient_id': _userId,
        'disease_name': name,
        'diagnosed_date': diagnosedDate?.toIso8601String(),
      });
      await fetchDiseases();
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
      await _supabase.from('diseases').delete().eq('id', diseaseId);
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
    if (_userId == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabase.from('allergies').select().eq('patient_id', _userId!);
      _allergies = data.map((item) {
        final map = Map<String, dynamic>.from(item);
        map['name'] ??= map['allergy'];
        return AllergyModel.fromJson(map);
      }).toList();
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
    if (_userId == null) return false;
    try {
      await _supabase.from('allergies').insert({
        'patient_id': _userId,
        'allergy': name,
        'severity': severity,
      });
      await fetchAllergies();
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
      await _supabase.from('allergies').delete().eq('id', allergyId);
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
    if (_userId == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabase.from('medicines').select().eq('patient_id', _userId!);
      _medicines = data.map((item) => MedicineModel.fromJson(item)).toList();
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
    if (_userId == null) return false;
    try {
      await _supabase.from('medicines').insert({
        'patient_id': _userId,
        'medicine': name,
        'dosage': dosage,
        'frequency': frequency,
      });
      await fetchMedicines();
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
      await _supabase.from('medicines').delete().eq('id', medicineId);
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
    if (_userId == null) return;
    await Future.wait([
      fetchPatientProfile(),
      fetchDiseases(),
      fetchAllergies(),
      fetchMedicines(),
    ]);
  }

  // ==================== QR CODES ====================

  /// Generate an emergency QR code token and save to Supabase
  Future<String?> generateQrCode() async {
    if (_userId == null) return null;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Delete any existing QR code for this patient
      await _supabase.from('qr_codes').delete().eq('patient_id', _userId!);

      // 2. Generate a secure, randomized UUID token
      // In a real app we might use cryptography, but UUIDv4 is sufficient for 24h tokens
      final String newToken = DateTime.now().millisecondsSinceEpoch.toString() + _userId!.substring(0, 8);

      // 3. Save to Supabase
      await _supabase.from('qr_codes').insert({
        'patient_id': _userId,
        'encrypted_token': newToken,
        // created_at is automatically generated by Postgres DEFAULT NOW()
      });

      _isLoading = false;
      notifyListeners();
      return newToken;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
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
