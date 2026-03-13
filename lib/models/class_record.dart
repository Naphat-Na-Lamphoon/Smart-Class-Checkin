class ClassRecord {
  ClassRecord({
    required this.id,
    required this.type,
    required this.timestampIso,
    required this.latitude,
    required this.longitude,
    required this.qrContent,
    this.previousTopic,
    this.expectedTopic,
    this.moodScore,
    this.learnedToday,
    this.feedback,
  });

  final String id;
  final String type;
  final String timestampIso;
  final double latitude;
  final double longitude;
  final String qrContent;

  final String? previousTopic;
  final String? expectedTopic;
  final int? moodScore;

  final String? learnedToday;
  final String? feedback;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timestampIso': timestampIso,
      'latitude': latitude,
      'longitude': longitude,
      'qrContent': qrContent,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'moodScore': moodScore,
      'learnedToday': learnedToday,
      'feedback': feedback,
    };
  }

  factory ClassRecord.fromJson(Map<String, dynamic> json) {
    return ClassRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      timestampIso: json['timestampIso'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      qrContent: json['qrContent'] as String,
      previousTopic: json['previousTopic'] as String?,
      expectedTopic: json['expectedTopic'] as String?,
      moodScore: json['moodScore'] as int?,
      learnedToday: json['learnedToday'] as String?,
      feedback: json['feedback'] as String?,
    );
  }
}
