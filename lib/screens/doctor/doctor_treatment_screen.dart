import 'package:flutter/material.dart';

class DoctorTreatmentScreen extends StatelessWidget {
  const DoctorTreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treatment Review')),
      body: const Center(
        child: Text('Treatment logging and review will appear here.'),
      ),
    );
  }
}
