import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/patient_provider.dart';

class EmergencyQrScreen extends StatefulWidget { const EmergencyQrScreen({super.key}); @override State<EmergencyQrScreen> createState() => _EmergencyQrScreenState(); }
class _EmergencyQrScreenState extends State<EmergencyQrScreen> {
  late Future<String?> _token;
  @override void initState() { super.initState(); _token = _load(); }
  Future<String?> _load() async { 
    final provider = context.read<PatientProvider>();
    return await provider.generateQrCode();
  }
  @override Widget build(BuildContext context) { final hasProfile = context.watch<PatientProvider>().patientProfile != null; return Scaffold(appBar: AppBar(title: const Text('Emergency QR Code')), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: !hasProfile ? const Text('Create your health profile before generating an emergency QR code.', textAlign: TextAlign.center) : FutureBuilder<String?>(future: _token, builder: (_, s) { if (s.connectionState != ConnectionState.done) return const CircularProgressIndicator(); if (s.hasError || !s.hasData || s.data!.isEmpty) return Column(mainAxisSize: MainAxisSize.min, children: [Text('Could not generate QR code: ${s.error ?? 'unknown error'}', textAlign: TextAlign.center), TextButton(onPressed: () => setState(() => _token = _load()), child: const Text('Try again'))]); return Column(mainAxisSize: MainAxisSize.min, children: [Card(elevation: 4, child: Padding(padding: const EdgeInsets.all(20), child: QrImageView(data: s.data!, version: QrVersions.auto, size: 240))), const SizedBox(height: 24), Text('Show this QR code in an emergency', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 8), Text('It provides securely encoded emergency access for authorised staff.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700]))]); }))), ); }
}
