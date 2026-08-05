import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PatientProvider>().fetchMedicines());
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Medicine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Medicine name'),
                ),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage', hintText: 'e.g. 500mg'),
                ),
                TextField(
                  controller: frequencyController,
                  decoration: const InputDecoration(labelText: 'Frequency', hintText: 'e.g. Twice daily'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await context.read<PatientProvider>().addMedicine(
                      name: nameController.text.trim(),
                      dosage: dosageController.text.trim(),
                      frequency: frequencyController.text.trim(),
                    );
                if (mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicines')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.medicines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.medicines.isEmpty) {
            return const Center(child: Text('No medicines added yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.medicines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final medicine = provider.medicines[index];
              return Card(
                child: ListTile(
                  title: Text(medicine.name),
                  subtitle: Text('${medicine.dosage} • ${medicine.frequency}'),
                  leading: const CircleAvatar(
                    child: Icon(Icons.medication),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<PatientProvider>().removeMedicine(medicine.id);
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
