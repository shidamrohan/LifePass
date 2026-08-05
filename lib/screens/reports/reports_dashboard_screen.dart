import 'package:flutter/material.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical Reports',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              icon: Icons.upload_file,
              title: 'Upload Report',
              subtitle: 'Add PDF, JPG, or PNG medical reports',
              onTap: () => Navigator.of(context).pushNamed('/reports/upload'),
            ),
            _buildCard(
              context,
              icon: Icons.history,
              title: 'Report History',
              subtitle: 'View previously uploaded reports',
              onTap: () => Navigator.of(context).pushNamed('/reports/history'),
            ),
            _buildCard(
              context,
              icon: Icons.summarize,
              title: 'AI Summary',
              subtitle: 'Show AI extracted medical summary',
              onTap: () => Navigator.of(context).pushNamed('/reports/summary'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
