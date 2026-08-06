import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ReportHistoryScreen extends StatefulWidget { const ReportHistoryScreen({super.key}); @override State<ReportHistoryScreen> createState() => _ReportHistoryScreenState(); }
class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  Future<List<dynamic>> _load() async { final r = await apiService.get<List<dynamic>>('/reports/history', fromJson: (j) => (j['reports'] as List?) ?? []); if (!r.success) throw Exception(r.error); return r.data ?? []; }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Report History')),
        body: FutureBuilder<List<dynamic>>(
          future: _load(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Could not load reports: ${snapshot.error}'));
            }
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) return const Center(child: Text('No reports uploaded yet.'));
            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (_, i) {
                  final report = reports[i] as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text((report['type'] as String? ?? 'Report').replaceAll('_', ' ')),
                    subtitle: Text('Uploaded: ${report['uploaded'] ?? '-'}'),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              ),
            );
          },
        ),
      );
}
