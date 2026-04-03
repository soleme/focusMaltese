import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_snapshot.dart';
import 'persistence_repository.dart';

class SharedPreferencesPersistenceRepository implements PersistenceRepository {
  const SharedPreferencesPersistenceRepository();

  static const _storageKey = 'focus_maltese_snapshot_v1';

  @override
  Future<AppSnapshot?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AppSnapshot.fromJson(decoded);
    } catch (_) {
      await prefs.remove(_storageKey);
      return null;
    }
  }

  @override
  Future<void> saveSnapshot(AppSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(snapshot.toJson()));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
