

// Patient profile model
class PatientModel {
  final int id;
  final int userId;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final String? bloodGroup; // 'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'
  final double? height; // cm
  final double? weight; // kg
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PatientModel({
    required this.id,
    required this.userId,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.height,
    this.weight,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      bloodGroup: json['blood_group'] as String?,
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'blood_group': bloodGroup,
      'height': height,
      'weight': weight,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PatientModel copyWith({
    int? id,
    int? userId,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    double? height,
    double? weight,
    String? emergencyContactName,
    String? emergencyContactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PatientModel(id: $id, userId: $userId, bloodGroup: $bloodGroup, gender: $gender)';
  }
}

// Disease model
class DiseaseModel {
  final int id;
  final int patientId;
  final String name;
  final DateTime? diagnosedDate;
  final DateTime? createdAt;

  DiseaseModel({
    required this.id,
    required this.patientId,
    required this.name,
    this.diagnosedDate,
    this.createdAt,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id'] as int? ?? 0,
      patientId: json['patient_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      diagnosedDate: json['diagnosed_date'] != null
          ? DateTime.parse(json['diagnosed_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'name': name,
      'diagnosed_date': diagnosedDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'DiseaseModel(id: $id, name: $name)';
}

// Allergy model
class AllergyModel {
  final int id;
  final int patientId;
  final String name;
  final String severity; // 'mild', 'moderate', 'severe'
  final DateTime? createdAt;

  AllergyModel({
    required this.id,
    required this.patientId,
    required this.name,
    required this.severity,
    this.createdAt,
  });

  factory AllergyModel.fromJson(Map<String, dynamic> json) {
    return AllergyModel(
      id: json['id'] as int? ?? 0,
      patientId: json['patient_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      severity: json['severity'] as String? ?? 'mild',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'name': name,
      'severity': severity,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'AllergyModel(id: $id, name: $name, severity: $severity)';
}

// Medicine model
class MedicineModel {
  final int id;
  final int patientId;
  final String name;
  final String dosage;
  final String frequency; // e.g., 'once daily', 'twice daily'
  final DateTime? createdAt;

  MedicineModel({
    required this.id,
    required this.patientId,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.createdAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] as int? ?? 0,
      patientId: json['patient_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'MedicineModel(id: $id, name: $name, dosage: $dosage, frequency: $frequency)';
}
