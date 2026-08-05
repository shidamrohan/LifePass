import 'package:flutter/material.dart';

class DoctorPatientScreen extends StatelessWidget {
  const DoctorPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profile')),
      body: const Center(
        child: Text('Patient lookup and emergency details will appear here.'),
      ),
    );
  }
}
