import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';

class DiseasesScreen extends StatefulWidget {
  const DiseasesScreen({super.key});

  @override
  State<DiseasesScreen> createState() => _DiseasesScreenState();
}

class _DiseasesScreenState extends State<DiseasesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PatientProvider>().fetchDiseases());
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Disease'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Disease name',
                        hintText: 'e.g. Diabetes',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Diagnosed date'),
                      subtitle: Text(
                        selectedDate == null
                            ? 'Select date'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
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
                    await context.read<PatientProvider>().addDisease(
                          name: nameController.text.trim(),
                          diagnosedDate: selectedDate,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diseases')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Disease'),
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.diseases.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.diseases.isEmpty) {
            return const Center(
              child: Text('No diseases added yet'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.diseases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final disease = provider.diseases[index];
              return Card(
                child: ListTile(
                  title: Text(disease.name),
                  subtitle: Text(
                    disease.diagnosedDate == null
                        ? 'Diagnosed date not set'
                        : 'Diagnosed: ${disease.diagnosedDate!.day}/${disease.diagnosedDate!.month}/${disease.diagnosedDate!.year}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<PatientProvider>().removeDisease(disease.id);
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
