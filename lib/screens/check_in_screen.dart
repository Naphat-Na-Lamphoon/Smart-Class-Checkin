import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/class_record.dart';
import '../services/local_storage_service.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({
    required this.storageService,
    required this.locationService,
    super.key,
  });

  final LocalStorageService storageService;
  final LocationService locationService;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();

  Position? _position;
  DateTime? _timestamp;
  String? _qrContent;
  int? _moodScore;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _captureLocationAndTime() async {
    try {
      final position = await widget.locationService.getCurrentPosition();
      if (!mounted) {
        return;
      }

      setState(() {
        _position = position;
        _timestamp = DateTime.now();
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

    if (_position == null || _timestamp == null) {
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

    if (_moodScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood before class')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final record = ClassRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: 'check_in',
      timestampIso: _timestamp!.toIso8601String(),
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      qrContent: _qrContent!,
      previousTopic: _previousTopicController.text.trim(),
      expectedTopic: _expectedTopicController.text.trim(),
      moodScore: _moodScore,
    );

    await widget.storageService.saveRecord(record);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in saved successfully')),
    );
    Navigator.of(context).pop(true);
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Not captured';
    }

    final date = value.toLocal();
    final minute = date.minute.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day ${date.hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Check-in')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FAFF), Color(0xFFEFF4FB)],
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
                  const _MissionHeader(),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _StatusTile(
                            icon: Icons.location_on,
                            title: 'Location + Time',
                            value: _position == null
                                ? 'Waiting for capture'
                                : '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
                            detail: 'Timestamp: ${_formatDate(_timestamp)}',
                            verified: _position != null && _timestamp != null,
                          ),
                          const SizedBox(height: 10),
                          _StatusTile(
                            icon: Icons.qr_code_scanner,
                            title: 'QR Validation',
                            value: _qrContent == null ? 'Waiting for scan' : _qrContent!,
                            detail: 'Use class QR provided by instructor',
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
                          onPressed: _captureLocationAndTime,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Capture GPS + Time'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _scanQrCode,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan QR'),
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
                          Text('Before Class Reflection', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _previousTopicController,
                            decoration: const InputDecoration(
                              labelText: 'What topic was covered in previous class?',
                            ),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Please enter previous class topic'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _expectedTopicController,
                            decoration: const InputDecoration(
                              labelText: 'What do you expect to learn today?',
                            ),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Please enter expected topic'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Mood before class (1-5)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MoodChip(
                                score: 1,
                                emoji: '😡',
                                label: 'Very negative',
                                selected: _moodScore == 1,
                                onTap: () => setState(() => _moodScore = 1),
                              ),
                              _MoodChip(
                                score: 2,
                                emoji: '🙁',
                                label: 'Negative',
                                selected: _moodScore == 2,
                                onTap: () => setState(() => _moodScore = 2),
                              ),
                              _MoodChip(
                                score: 3,
                                emoji: '😐',
                                label: 'Neutral',
                                selected: _moodScore == 3,
                                onTap: () => setState(() => _moodScore = 3),
                              ),
                              _MoodChip(
                                score: 4,
                                emoji: '🙂',
                                label: 'Positive',
                                selected: _moodScore == 4,
                                onTap: () => setState(() => _moodScore = 4),
                              ),
                              _MoodChip(
                                score: 5,
                                emoji: '😄',
                                label: 'Very positive',
                                selected: _moodScore == 5,
                                onTap: () => setState(() => _moodScore = 5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: const Icon(Icons.task_alt),
                    label: Text(_isSubmitting ? 'Saving...' : 'Submit Check-in'),
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

class _MissionHeader extends StatelessWidget {
  const _MissionHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1155CC), Color(0xFF2A9D8F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Before Class Mission',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Validate your attendance with location + QR, then submit learning expectations.',
              style: TextStyle(color: Color(0xFFEDF3FF), height: 1.35),
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

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.score,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int score;
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$score'),
          const SizedBox(width: 4),
          Text(emoji),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: const Color(0xFF1155CC).withValues(alpha: 0.18),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? const Color(0xFF0A2B68) : const Color(0xFF334155),
      ),
      side: BorderSide(
        color: selected ? const Color(0xFF1155CC) : const Color(0xFFD1D9E5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    );
  }
}
