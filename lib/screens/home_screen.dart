import 'package:flutter/material.dart';

import '../models/class_record.dart';
import '../services/local_storage_service.dart';
import '../services/location_service.dart';
import 'check_in_screen.dart';
import 'finish_class_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.storageService,
    required this.locationService,
    super.key,
  });

  final LocalStorageService storageService;
  final LocationService locationService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<ClassRecord>>? _recordsFuture;

  @override
  void initState() {
    super.initState();
    _reloadRecords();
  }

  void _reloadRecords() {
    setState(() {
      _recordsFuture = widget.storageService.getRecords();
    });
  }

  Future<void> _refreshRecords() async {
    await widget.storageService.getRecords();
    if (mounted) {
      _reloadRecords();
    }
  }

  Future<void> _openCheckIn() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CheckInScreen(
          storageService: widget.storageService,
          locationService: widget.locationService,
        ),
      ),
    );

    if (saved == true) {
      _reloadRecords();
    }
  }

  Future<void> _openFinishClass() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FinishClassScreen(
          storageService: widget.storageService,
          locationService: widget.locationService,
        ),
      ),
    );

    if (saved == true) {
      _reloadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FAFF), Color(0xFFEFF4FB)],
          ),
        ),
        child: Stack(
          children: [
            const _BackdropShapes(),
            SafeArea(
              child: FutureBuilder<List<ClassRecord>>(
                future: _recordsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  }

                  final records = snapshot.data ?? [];
                  final checkInCount =
                      records.where((record) => record.type == 'check_in').length;
                  final finishCount = records.where((record) => record.type == 'finish').length;

                  return RefreshIndicator(
                    onRefresh: _refreshRecords,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        const _HeaderBlock(),
                        const SizedBox(height: 16),
                        _MissionCard(
                          icon: Icons.login,
                          title: 'Before Class Mission',
                          subtitle:
                              'Capture GPS + time, scan class QR, and submit your pre-class reflection.',
                          buttonText: 'Check-in (Before Class)',
                          gradientColors: const [Color(0xFF1155CC), Color(0xFF2A9D8F)],
                          onPressed: _openCheckIn,
                        ),
                        const SizedBox(height: 12),
                        _MissionCard(
                          icon: Icons.logout,
                          title: 'After Class Mission',
                          subtitle:
                              'Scan QR again, capture location, and summarize what you learned today.',
                          buttonText: 'Finish Class (After Class)',
                          gradientColors: const [Color(0xFFF4A000), Color(0xFFE76F51)],
                          onPressed: _openFinishClass,
                        ),
                        const SizedBox(height: 18),
                        Text('Session Snapshot', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Total',
                                value: records.length.toString(),
                                tone: const Color(0xFF006D77),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                label: 'Check-in',
                                value: checkInCount.toString(),
                                tone: const Color(0xFF1155CC),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                label: 'Finish',
                                value: finishCount.toString(),
                                tone: const Color(0xFFE76F51),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('Recent Records', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        if (records.isEmpty)
                          const _EmptyRecordsCard()
                        else
                          ...records.take(10).map(_RecordTile.new),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1220), Color(0xFF12335D)],
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Class Check-in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'GPS + QR + Reflection\nA compact workflow to validate attendance and participation.',
              style: TextStyle(color: Color(0xFFE8EDF8), height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradientColors,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFFF4F7FB), height: 1.4),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0B1220),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.tone});

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF425066))),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: tone,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecordsCard extends StatelessWidget {
  const _EmptyRecordsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 38, color: Color(0xFF7A889D)),
            SizedBox(height: 8),
            Text('No records yet'),
            SizedBox(height: 2),
            Text(
              'Start with Check-in before class to create the first session record.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF5A6679)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile(this.record);

  final ClassRecord record;

  String _labelByType() => record.type == 'check_in' ? 'Check-in' : 'Finish';

  Color _toneByType() =>
      record.type == 'check_in' ? const Color(0xFF1155CC) : const Color(0xFFE76F51);

  String _moodEmoji(int score) {
    switch (score) {
      case 1:
        return '😡';
      case 2:
        return '🙁';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '';
    }
  }

  String _moodLabel(int score) {
    switch (score) {
      case 1:
        return 'Very negative';
      case 2:
        return 'Negative';
      case 3:
        return 'Neutral';
      case 4:
        return 'Positive';
      case 5:
        return 'Very positive';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso)?.toLocal();
    if (parsed == null) {
      return iso;
    }

    final twoDigitsMinute = parsed.minute.toString().padLeft(2, '0');
    final twoDigitsMonth = parsed.month.toString().padLeft(2, '0');
    final twoDigitsDay = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$twoDigitsMonth-$twoDigitsDay ${parsed.hour}:$twoDigitsMinute';
  }

  @override
  Widget build(BuildContext context) {
    final tone = _toneByType();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tone.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _labelByType(),
                          style: TextStyle(color: tone, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(record.timestampIso),
                        style: const TextStyle(color: Color(0xFF5E6B80), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${record.latitude.toStringAsFixed(5)}, ${record.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'QR: ${record.qrContent}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF425066)),
                  ),
                  if (record.type == 'check_in' && record.moodScore != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Mood: ${record.moodScore} ${_moodEmoji(record.moodScore!)} ${_moodLabel(record.moodScore!)}',
                      style: const TextStyle(color: Color(0xFF425066)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackdropShapes extends StatelessWidget {
  const _BackdropShapes();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A9D8F).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1155CC).withValues(alpha: 0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
