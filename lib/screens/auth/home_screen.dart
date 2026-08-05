import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifePass Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(colorScheme: colorScheme),
            const SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionCard(icon: Icons.person_add, title: 'Create Profile', onTap: () => Navigator.of(context).pushNamed('/profile/create')),
                _ActionCard(icon: Icons.person, title: 'View Profile', onTap: () => Navigator.of(context).pushNamed('/profile/view')),
                _ActionCard(icon: Icons.medical_information, title: 'Diseases', onTap: () => Navigator.of(context).pushNamed('/medical/diseases')),
                _ActionCard(icon: Icons.warning, title: 'Allergies', onTap: () => Navigator.of(context).pushNamed('/medical/allergies')),
                _ActionCard(icon: Icons.medication, title: 'Medicines', onTap: () => Navigator.of(context).pushNamed('/medical/medicines')),
                _ActionCard(icon: Icons.description, title: 'Reports', onTap: () => Navigator.of(context).pushNamed('/reports')),
                _ActionCard(icon: Icons.settings, title: 'Settings', onTap: () => Navigator.of(context).pushNamed('/settings')),
                _ActionCard(icon: Icons.logout, title: 'Logout', danger: true, onTap: () => _confirmLogout(context)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Clinical Tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _SectionButton(icon: Icons.shield_outlined, label: 'Emergency Profile', onPressed: () => Navigator.of(context).pushNamed('/emergency/profile')),
            _SectionButton(icon: Icons.qr_code_2, label: 'Emergency QR', onPressed: () => Navigator.of(context).pushNamed('/emergency/qr')),
            _SectionButton(icon: Icons.local_hospital, label: 'Doctor Dashboard', onPressed: () => Navigator.of(context).pushNamed('/doctor/dashboard')),
            _SectionButton(icon: Icons.receipt_long, label: 'Audit Logs', onPressed: () => Navigator.of(context).pushNamed('/doctor/audit-logs')),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const _HeroCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.health_and_safety, color: colorScheme.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${authProvider.user?.name ?? 'User'}!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.user?.email ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Emergency health access, profile, reports and doctor tools in one place.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 28,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SectionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }
}
