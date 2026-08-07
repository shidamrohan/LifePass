import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportHistoryScreen extends StatefulWidget { const ReportHistoryScreen({super.key}); @override State<ReportHistoryScreen> createState() => _ReportHistoryScreenState(); }
class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  Future<List<dynamic>> _load() async {
    final patientId = Supabase.instance.client.auth.currentUser?.id;
    if (patientId == null) return [];
    return await Supabase.instance.client
        .from('medical_reports')
        .select('*')
        .eq('patient_id', patientId)
        .order('upload_date', ascending: false);
  }
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
                    title: Text((report['report_type'] as String? ?? 'Report').replaceAll('_', ' ')),
                    subtitle: Text('Uploaded: ${report['upload_date'] ?? '-'}'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () async {
                      final urlStr = report['file_url'] as String?;
                      if (urlStr != null) {
                        final url = Uri.parse(urlStr);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open report file.')),
                            );
                          }
                        }
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      );
}
