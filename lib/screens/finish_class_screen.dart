import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/class_record.dart';
import '../services/local_storage_service.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({
    required this.storageService,
    required this.locationService,
    super.key,
  });

  final LocalStorageService storageService;
  final LocationService locationService;

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();

  Position? _position;
  String? _qrContent;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    try {
      final position = await widget.locationService.getCurrentPosition();
      if (!mounted) {
        return;
      }

      setState(() {
        _position = position;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot get location: $error')),
      );
    }
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _qrContent = result;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture GPS location first')),
      );
      return;
    }

    if (_qrContent == null || _qrContent!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan QR code')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final record = ClassRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: 'finish',
      timestampIso: DateTime.now().toIso8601String(),
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      qrContent: _qrContent!,
      learnedToday: _learnedTodayController.text.trim(),
      feedback: _feedbackController.text.trim(),
    );

    await widget.storageService.saveRecord(record);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finish class saved successfully')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF9F2), Color(0xFFF7F0E6)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _FinishMissionHeader(),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _StatusTile(
                            icon: Icons.location_on,
                            title: 'Checkout Location',
                            value: _position == null
                                ? 'Waiting for capture'
                                : '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
                            detail: 'Capture location at class end',
                            verified: _position != null,
                          ),
                          const SizedBox(height: 10),
                          _StatusTile(
                            icon: Icons.qr_code_scanner,
                            title: 'QR Validation',
                            value: _qrContent == null ? 'Waiting for scan' : _qrContent!,
                            detail: 'Scan class QR again to complete session',
                            verified: _qrContent != null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _captureLocation,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Capture GPS'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _scanQrCode,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan QR Again'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('After Class Reflection', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _learnedTodayController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'What did you learn today? (short text)',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Please fill this field'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _feedbackController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Feedback for class or instructor',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Please fill this field'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: const Icon(Icons.task_alt),
                    label: Text(_isSubmitting ? 'Saving...' : 'Submit Finish Class'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishMissionHeader extends StatelessWidget {
  const _FinishMissionHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFF4A000), Color(0xFFE76F51)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'After Class Mission',
              style: TextStyle(color: Color(0xFF1B1306), fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Complete checkout verification and summarize your learning from this class session.',
              style: TextStyle(color: Color(0xFF2A2112), height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.verified,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final tone = verified ? const Color(0xFF0D9488) : const Color(0xFFB45309);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        verified ? 'Verified' : 'Pending',
                        style: TextStyle(color: tone, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(detail, style: const TextStyle(color: Color(0xFF4B5567), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
