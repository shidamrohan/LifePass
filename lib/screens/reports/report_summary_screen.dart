import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ReportSummaryScreen extends StatefulWidget { const ReportSummaryScreen({super.key}); @override State<ReportSummaryScreen> createState() => _ReportSummaryScreenState(); }
class _ReportSummaryScreenState extends State<ReportSummaryScreen> {
  Future<Map<String, dynamic>> _load() async { final r = await apiService.get<Map<String, dynamic>>('/reports/summary', fromJson: (j) => j as Map<String, dynamic>); if (!r.success) throw Exception(r.error); return r.data!; }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('AI Summary')), body: FutureBuilder<Map<String, dynamic>>(future: _load(), builder: (_, s) { if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator()); if (s.hasError) return Center(child: Text('Could not load summary: ${s.error}')); final data=s.data!; final summary=data['summary'] as String?; if (summary == null || summary.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Upload a report to generate your medical summary.', textAlign: TextAlign.center))); return Padding(padding: const EdgeInsets.all(16), child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Risk level: ${data['risk_level'] ?? 'not available'}', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 16), Text(summary)])))); }));
}
