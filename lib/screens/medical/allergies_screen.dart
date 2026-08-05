import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';

class AllergiesScreen extends StatefulWidget {
  const AllergiesScreen({super.key});

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PatientProvider>().fetchAllergies());
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    String severity = 'mild';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Allergy'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Allergy name',
                      hintText: 'e.g. Peanut',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: severity,
                    items: const [
                      DropdownMenuItem(value: 'mild', child: Text('Mild')),
                      DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                      DropdownMenuItem(value: 'severe', child: Text('Severe')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => severity = value);
                    },
                    decoration: const InputDecoration(labelText: 'Severity'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    await context.read<PatientProvider>().addAllergy(
                          name: nameController.text.trim(),
                          severity: severity,
                        );
                    if (mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Allergies')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Allergy'),
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allergies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allergies.isEmpty) {
            return const Center(child: Text('No allergies added yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.allergies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final allergy = provider.allergies[index];
              return Card(
                child: ListTile(
                  title: Text(allergy.name),
                  subtitle: Text('Severity: ${allergy.severity}'),
                  leading: CircleAvatar(
                    backgroundColor: _severityColor(allergy.severity).withOpacity(0.15),
                    child: Icon(Icons.warning, color: _severityColor(allergy.severity)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<PatientProvider>().removeAllergy(allergy.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
