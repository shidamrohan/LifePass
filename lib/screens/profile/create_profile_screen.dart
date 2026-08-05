import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../config/app_constants.dart';
import '../../widgets/custom_widgets.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    _dobController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final patientProvider = context.read<PatientProvider>();
    final success = await patientProvider.savePatientProfile(
      dateOfBirth: _selectedDob,
      gender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
      height: double.tryParse(_heightController.text.trim()),
      weight: double.tryParse(_weightController.text.trim()),
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (context) => SuccessDialog(
          title: 'Profile Saved',
          message: 'Patient profile created successfully.',
          onOkPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          message: patientProvider.error ?? 'Failed to save profile.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Patient Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Date of Birth',
                hint: 'Select your date of birth',
                controller: _dobController,
                validator: (value) => value == null || value.isEmpty ? 'Date of birth is required' : null,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Pick Date',
                onPressed: _pickDateOfBirth,
              ),
              const SizedBox(height: 20),
              CustomDropdownField<String>(
                label: 'Gender',
                value: _selectedGender,
                items: AppConstants.genderOptions,
                getLabel: (value) => value,
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 20),
              CustomDropdownField<String>(
                label: 'Blood Group',
                value: _selectedBloodGroup,
                items: AppConstants.bloodGroups,
                getLabel: (value) => value,
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Height (cm)',
                hint: 'Enter height',
                controller: _heightController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Height is required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Weight (kg)',
                hint: 'Enter weight',
                controller: _weightController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Weight is required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Emergency Contact Name',
                hint: 'Enter emergency contact name',
                controller: _emergencyNameController,
                validator: (value) => value == null || value.isEmpty ? 'Emergency contact name is required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Emergency Contact Phone',
                hint: 'Enter emergency contact phone',
                controller: _emergencyPhoneController,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Emergency contact phone is required' : null,
              ),
              const SizedBox(height: 28),
              Consumer<PatientProvider>(
                builder: (context, provider, _) => PrimaryButton(
                  label: 'Save Profile',
                  isLoading: provider.isLoading,
                  onPressed: _saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
