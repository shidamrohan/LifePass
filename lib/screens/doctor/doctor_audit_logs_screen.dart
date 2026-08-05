import 'package:flutter/material.dart';

class DoctorAuditLogsScreen extends StatelessWidget {
  const DoctorAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: const Center(
        child: Text('Audit trail and access logs will appear here.'),
      ),
    );
  }
}
