import 'package:flutter/material.dart';

class ReportSummaryScreen extends StatelessWidget {
  const ReportSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Summary')),
      body: const Center(
        child: Text('AI extracted medical summary will appear here.'),
      ),
    );
  }
}
