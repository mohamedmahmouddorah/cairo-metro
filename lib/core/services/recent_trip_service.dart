import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/recent_trip.dart';

class RecentTripService {
  static const _key = 'metro_recent_trip';

  Future<void> save(RecentTrip trip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(trip.toJson()));
  }

  Future<RecentTrip?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return RecentTrip.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}