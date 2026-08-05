import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';

class EmergencyQrScreen extends StatelessWidget {
  const EmergencyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final patientProvider = context.watch<PatientProvider>();
    final profile = patientProvider.patientProfile;

    final qrData = {
      'user': authProvider.user?.name ?? 'Unknown',
      'email': authProvider.user?.email ?? '',
      'patient_id': profile?.id ?? 0,
      'blood_group': profile?.bloodGroup ?? '',
      'emergency_contact': profile?.emergencyContactPhone ?? '',
    }.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency QR Code')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 240,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Show this QR code in an emergency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'It contains quick access emergency details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
