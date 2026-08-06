import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../medical/diseases_screen.dart';
import '../medical/allergies_screen.dart';
import '../medical/medicines_screen.dart';
import '../reports/reports_dashboard_screen.dart';
import '../emergency/emergency_qr_screen.dart';
import '../settings/settings_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Static screens - initialized once, not rebuilt on every frame
  late final List<Widget> _staticPages;

  // ── Notifications ──────────────────────────────────────────
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.health_and_safety,
      'color': Colors.green,
      'title': 'Profile Setup Reminder',
      'body': 'Complete your emergency health profile for better coverage.',
      'time': '2 min ago',
      'read': false,
    },
    {
      'icon': Icons.qr_code_2,
      'color': Colors.blue,
      'title': 'QR Code Ready',
      'body': 'Your emergency QR pass is active and scannable by doctors.',
      'time': '1 hr ago',
      'read': false,
    },
    {
      'icon': Icons.medication,
      'color': Colors.orange,
      'title': 'Medication Reminder',
      'body': 'Keep your medication list updated for accurate emergency info.',
      'time': '3 hr ago',
      'read': true,
    },
    {
      'icon': Icons.upload_file,
      'color': Colors.indigo,
      'title': 'Upload Medical Reports',
      'body': 'Upload your latest reports for AI-powered health summaries.',
      'time': 'Yesterday',
      'read': true,
    },
  ];

  int get _unreadCount =>
      _notifications.where((n) => n['read'] == false).length;

  @override
  void initState() {
    super.initState();
    // Initialize static pages once to avoid rebuilding them on every frame
    _staticPages = const [
      ReportsDashboardScreen(),
      EmergencyQrScreen(),
      SettingsDashboardScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatientData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final patientProvider = context.watch<PatientProvider>();

    // Only dashboard and medical tab depend on providers — rebuild those when needed
    final List<Widget> pages = [
      _buildDashboard(context, authProvider, patientProvider),
      _buildMedicalTab(context),
      _staticPages[0], // ReportsDashboardScreen
      _staticPages[1], // EmergencyQrScreen
      _staticPages[2], // SettingsDashboardScreen
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Medical',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_2_outlined),
            selectedIcon: Icon(Icons.qr_code_2),
            label: 'Emergency',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HOME TAB
  // ─────────────────────────────────────────────────────────────
  Widget _buildDashboard(
    BuildContext context,
    AuthProvider auth,
    PatientProvider patient,
  ) {
    final profile = patient.patientProfile;
    final diseases = patient.diseases;
    final allergies = patient.allergies;
    final medicines = patient.medicines;
    final userName = auth.user?.name ?? 'Patient';

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final wide = constraints.maxWidth > 600;
        return RefreshIndicator(
          onRefresh: () async => patient.fetchPatientData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 32 : 16,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────
                    Row(
                      children: [
                        // Tappable Avatar → User Profile Sheet
                        GestureDetector(
                          onTap: () => _showUserProfileSheet(context, auth, patient),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFF2E7D32),
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'P',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent[400],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $userName 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                              ),
                              Text(
                                'LifePass Emergency ID Active',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Blood group badge
                        if (profile?.bloodGroup != null &&
                            profile!.bloodGroup!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bloodtype,
                                    color: Colors.red, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  profile.bloodGroup!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 6),
                        // Notification Bell
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  size: 28),
                              tooltip: 'Notifications',
                              onPressed: () =>
                                  _showNotificationsSheet(context),
                            ),
                            if (_unreadCount > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '$_unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Emergency Hero Banner ────────────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1B5E20).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shield,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'EMERGENCY PASS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.qr_code_2,
                                    color: Colors.white, size: 28),
                                onPressed: () =>
                                    setState(() => _currentIndex = 3),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Instant Doctor Access',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Show your QR code to emergency responders for instant critical health data access.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () =>
                                    setState(() => _currentIndex = 3),
                                icon: const Icon(Icons.qr_code, size: 18),
                                label: const Text('Show Emergency QR'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1B5E20),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/emergency/profile'),
                                icon: const Icon(Icons.remove_red_eye,
                                    size: 18, color: Colors.white),
                                label: const Text('View Full Pass',
                                    style:
                                        TextStyle(color: Colors.white)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.white, width: 1.5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Summary Pills ────────────────────────────
                    Text(
                      'Emergency Medical Summary',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context,
                            icon: Icons.coronavirus_outlined,
                            title: 'Diseases',
                            count: diseases.length,
                            subtitle: diseases.isNotEmpty
                                ? diseases.first.name
                                : 'None',
                            color: Colors.orange,
                            onTap: () => Navigator.of(context)
                                .pushNamed('/medical/diseases'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            context,
                            icon: Icons.warning_amber_rounded,
                            title: 'Allergies',
                            count: allergies.length,
                            subtitle: allergies.isNotEmpty
                                ? allergies.first.name
                                : 'None',
                            color: Colors.red,
                            onTap: () => Navigator.of(context)
                                .pushNamed('/medical/allergies'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            context,
                            icon: Icons.medication_outlined,
                            title: 'Meds',
                            count: medicines.length,
                            subtitle: medicines.isNotEmpty
                                ? medicines.first.name
                                : 'None',
                            color: Colors.blue,
                            onTap: () => Navigator.of(context)
                                .pushNamed('/medical/medicines'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Quick Actions Grid ───────────────────────
                    Text(
                      'Quick Actions',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: wide ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.35,
                      children: [
                        _gridTile(
                          context,
                          icon: Icons.person_outline,
                          title: 'My Profile',
                          subtitle: 'View & Edit',
                          color: const Color(0xFF2E7D32),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/profile/view'),
                        ),
                        _gridTile(
                          context,
                          icon: Icons.folder_open,
                          title: 'Reports',
                          subtitle: 'PDF / Image OCR',
                          color: Colors.indigo,
                          onTap: () => setState(() => _currentIndex = 2),
                        ),
                        _gridTile(
                          context,
                          icon: Icons.medical_information_outlined,
                          title: 'Medical History',
                          subtitle: 'Diseases & Meds',
                          color: Colors.teal,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                        _gridTile(
                          context,
                          icon: Icons.health_and_safety_outlined,
                          title: 'Emergency Pass',
                          subtitle: 'Critical details',
                          color: Colors.red,
                          onTap: () => Navigator.of(context)
                              .pushNamed('/emergency/profile'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Emergency Contact Card ───────────────────
                    Card(
                      elevation: 0,
                      color: Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.red[200]!),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: const Icon(Icons.phone_in_talk,
                              color: Colors.red),
                        ),
                        title: Text(
                          profile?.emergencyContactName ?? 'No Emergency Contact',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        subtitle: Text(
                          profile?.emergencyContactPhone ??
                              'Tap Profile to add a contact',
                          style: TextStyle(color: Colors.red[900]),
                        ),
                        trailing: profile?.emergencyContactPhone != null
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Calling: ${profile!.emergencyContactPhone}'),
                                      backgroundColor: Colors.red[700],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.call, size: 16),
                                label: const Text('Call'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                ),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // USER PROFILE BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────
  void _showUserProfileSheet(
    BuildContext context,
    AuthProvider auth,
    PatientProvider patient,
  ) {
    final user = auth.user;
    final profile = patient.patientProfile;
    final diseases = patient.diseases;
    final allergies = patient.allergies;
    final medicines = patient.medicines;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Avatar + Name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: const Color(0xFF2E7D32),
                      child: Text(
                        (user?.name ?? 'P').isNotEmpty
                            ? (user?.name ?? 'P')[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Patient',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Text(
                        'LifePass Member',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Account Details
              _sheetSection('Account Details', [
                _sheetInfoRow(
                    Icons.email_outlined, 'Email', user?.email ?? '—'),
                _sheetInfoRow(Icons.phone_outlined, 'Phone',
                    user?.phone ?? '—'),
                _sheetInfoRow(Icons.badge_outlined, 'Role',
                    (user?.role ?? 'patient').toUpperCase()),
              ]),

              const SizedBox(height: 16),

              // Health Profile
              _sheetSection('Health Profile', [
                _sheetInfoRow(Icons.cake_outlined, 'Date of Birth',
                    profile?.dateOfBirth != null
                        ? '${profile!.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}'
                        : '—'),
                _sheetInfoRow(
                    Icons.wc_outlined, 'Gender', profile?.gender ?? '—'),
                _sheetInfoRow(Icons.bloodtype_outlined, 'Blood Group',
                    profile?.bloodGroup ?? '—'),
                _sheetInfoRow(Icons.height_outlined, 'Height',
                    profile?.height != null
                        ? '${profile!.height} cm'
                        : '—'),
                _sheetInfoRow(Icons.monitor_weight_outlined, 'Weight',
                    profile?.weight != null
                        ? '${profile!.weight} kg'
                        : '—'),
              ]),

              const SizedBox(height: 16),

              // Emergency Contact
              _sheetSection('Emergency Contact', [
                _sheetInfoRow(Icons.person_outline, 'Name',
                    profile?.emergencyContactName ?? '—'),
                _sheetInfoRow(Icons.phone_in_talk_outlined, 'Phone',
                    profile?.emergencyContactPhone ?? '—'),
              ]),

              const SizedBox(height: 16),

              // Medical Summary chips
              _sheetSection('Medical Summary', []),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _summaryChip('${diseases.length} Diseases',
                      Icons.coronavirus, Colors.orange),
                  _summaryChip('${allergies.length} Allergies',
                      Icons.warning_amber, Colors.red),
                  _summaryChip('${medicines.length} Medicines',
                      Icons.medication, Colors.blue),
                ],
              ),

              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/profile/view');
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        auth.logout();
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  Widget _sheetInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color[800],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // NOTIFICATIONS BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => StatefulBuilder(
          builder: (ctx, setSheetState) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 12, 12, 0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                for (var n in _notifications) {
                                  n['read'] = true;
                                }
                              });
                              setState(() {}); // update bell badge
                            },
                            child: const Text('Mark all read'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // List
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 70),
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      final bool unread = n['read'] == false;
                      return InkWell(
                        onTap: () {
                          setSheetState(
                              () => n['read'] = true);
                          setState(() {}); // update badge
                        },
                        child: Container(
                          color: unread
                              ? (n['color'] as MaterialColor)[50]
                              : null,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: (n['color']
                                        as MaterialColor)[100],
                                child: Icon(
                                  n['icon'] as IconData,
                                  color: (n['color']
                                      as MaterialColor)[700],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n['title'] as String,
                                            style: TextStyle(
                                              fontWeight: unread
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (unread)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration:
                                                const BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['body'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['time'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required String subtitle,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color[700], size: 20),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color[900]),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: color[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MEDICAL TAB  (TabBar inside the nav shell)
  // ─────────────────────────────────────────────────────────────
  Widget _buildMedicalTab(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medical History'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.coronavirus), text: 'Diseases'),
              Tab(icon: Icon(Icons.warning), text: 'Allergies'),
              Tab(icon: Icon(Icons.medication), text: 'Medicines'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DiseasesScreen(),
            AllergiesScreen(),
            MedicinesScreen(),
          ],
        ),
      ),
    );
  }
}
