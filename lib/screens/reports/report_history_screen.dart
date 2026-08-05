import 'package:flutter/material.dart';

class ReportHistoryScreen extends StatelessWidget {
  const ReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report History')),
      body: const Center(
        child: Text('Uploaded reports will be listed here.'),
      ),
    );
  }
}
