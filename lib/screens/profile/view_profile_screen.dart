import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PatientProvider>().patientProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).pushNamed('/profile/edit'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: profile == null
            ? const Center(child: Text('No profile found'))
            : ListView(
                children: [
                  _infoTile('Date of Birth', profile.dateOfBirth?.toIso8601String() ?? '-'),
                  _infoTile('Gender', profile.gender ?? '-'),
                  _infoTile('Blood Group', profile.bloodGroup ?? '-'),
                  _infoTile('Height', profile.height?.toString() ?? '-'),
                  _infoTile('Weight', profile.weight?.toString() ?? '-'),
                  _infoTile('Emergency Contact Name', profile.emergencyContactName ?? '-'),
                  _infoTile('Emergency Contact Phone', profile.emergencyContactPhone ?? '-'),
                ],
              ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
