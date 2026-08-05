import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';

class EmergencyProfileScreen extends StatelessWidget {
  const EmergencyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    final profile = patientProvider.patientProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => Navigator.of(context).pushNamed('/emergency/qr'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await patientProvider.fetchPatientProfile();
          await patientProvider.fetchAllergies();
          await patientProvider.fetchDiseases();
          await patientProvider.fetchMedicines();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(profile: profile),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Critical Details',
              child: Column(
                children: [
                  _InfoRow(label: 'Blood Group', value: profile?.bloodGroup ?? '-'),
                  _InfoRow(label: 'Gender', value: profile?.gender ?? '-'),
                  _InfoRow(label: 'Date of Birth', value: _formatDate(profile?.dateOfBirth)),
                  _InfoRow(label: 'Emergency Contact', value: profile?.emergencyContactName ?? '-'),
                  _InfoRow(label: 'Emergency Phone', value: profile?.emergencyContactPhone ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Allergies',
              child: patientProvider.allergies.isEmpty
                  ? const Text('No allergies added')
                  : Column(
                      children: patientProvider.allergies
                          .map(
                            (allergy) => _InfoRow(
                              label: allergy.name,
                              value: allergy.severity.toUpperCase(),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Medicines',
              child: patientProvider.medicines.isEmpty
                  ? const Text('No medicines added')
                  : Column(
                      children: patientProvider.medicines
                          .map(
                            (medicine) => _InfoRow(
                              label: medicine.name,
                              value: '${medicine.dosage} • ${medicine.frequency}',
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Diseases',
              child: patientProvider.diseases.isEmpty
                  ? const Text('No diseases added')
                  : Column(
                      children: patientProvider.diseases
                          .map(
                            (disease) => _InfoRow(
                              label: disease.name,
                              value: disease.diagnosedDate == null
                                  ? 'Date not set'
                                  : _formatDate(disease.diagnosedDate),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/emergency/qr'),
              icon: const Icon(Icons.qr_code),
              label: const Text('Show Emergency QR'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _HeaderCard extends StatelessWidget {
  final dynamic profile;

  const _HeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.health_and_safety, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Health Profile',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile == null
                        ? 'No profile created yet'
                        : 'Fast access information for emergencies',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
