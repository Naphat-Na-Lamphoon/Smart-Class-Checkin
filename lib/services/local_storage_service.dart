import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/class_record.dart';

class LocalStorageService {
  static const _recordKey = 'class_records';

  Future<List<ClassRecord>> getRecords() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_recordKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ClassRecord.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestampIso.compareTo(a.timestampIso));
  }

  Future<void> saveRecord(ClassRecord record) async {
    final preferences = await SharedPreferences.getInstance();
    final records = await getRecords();
    records.add(record);

    final encoded = jsonEncode(records.map((record) => record.toJson()).toList());
    await preferences.setString(_recordKey, encoded);
  }
}
