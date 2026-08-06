import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class ReportUploadScreen extends StatefulWidget {
  const ReportUploadScreen({super.key});
  @override State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  XFile? _file;
  String _type = 'lab_report';
  bool _uploading = false;

  Future<void> _chooseFile() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file != null && mounted) setState(() => _file = file);
  }

  Future<void> _upload() async {
    if (_file == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a report image first.'))); return; }
    setState(() => _uploading = true);
    final result = await apiService.uploadReport(path: _file!.path, reportType: _type);
    if (!mounted) return;
    setState(() => _uploading = false);
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report uploaded and processed successfully.')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error ?? 'Could not upload report.')));
    }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Upload Report')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Icon(Icons.cloud_upload_outlined, size: 88), const SizedBox(height: 16),
      Text('Upload a medical report image', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8), const Text('Choose a clear JPG or PNG image from your device.', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      DropdownButtonFormField<String>(value: _type, decoration: const InputDecoration(labelText: 'Report type', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'lab_report', child: Text('Lab report')), DropdownMenuItem(value: 'prescription', child: Text('Prescription')), DropdownMenuItem(value: 'discharge_summary', child: Text('Discharge summary'))], onChanged: (value) => setState(() => _type = value!)),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: _uploading ? null : _chooseFile, icon: const Icon(Icons.attach_file), label: Text(_file == null ? 'Choose Image' : _file!.name)),
      const SizedBox(height: 12),
      ElevatedButton.icon(onPressed: _uploading ? null : _upload, icon: _uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload), label: Text(_uploading ? 'Uploading…' : 'Upload Report')),
    ])),
  );
}
