import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/metro_data.dart';
import '../../data/models/metro_station.dart';
import '../../data/models/place_result.dart';
import '../app_constants.dart';

class SearchHistory {
  final MetroStation startStation;
  final MetroStation endStation;
  final DateTime date;

  const SearchHistory({
    required this.startStation,
    required this.endStation,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'start': startStation.id,
        'end': endStation.id,
        'date': date.toIso8601String(),
      };

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    final start = MetroData.stationById(json['start'] as String);
    final end = MetroData.stationById(json['end'] as String);
    if (start == null || end == null) {
      throw const FormatException('Unknown station in history');
    }
    return SearchHistory(
      startStation: start,
      endStation: end,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class HistoryService {
  static const String _key = 'metro_search_history';
  static const String _placeKey = 'metro_place_search_history';
  static const String _lastStartKey = 'last_start_station_id';
  static const String _lastEndKey = 'last_end_station_id';

  Future<void> saveLastSelectedStations(String? startStationId, String? endStationId) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (startStationId != null) {
      await prefs.setString(_lastStartKey, startStationId);
    } else {
      await prefs.remove(_lastStartKey);
    }

    if (endStationId != null) {
      await prefs.setString(_lastEndKey, endStationId);
    } else {
      await prefs.remove(_lastEndKey);
    }
  }

  Future<String?> getLastStartStationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastStartKey);
  }

  Future<String?> getLastEndStationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastEndKey);
  }

  Future<void> saveSearch(MetroStation start, MetroStation end) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.removeWhere((h) => h.startStation.id == start.id && h.endStation.id == end.id);
    history.insert(0, SearchHistory(startStation: start, endStation: end, date: DateTime.now()));

    if (history.length > 20) {
      history.removeRange(20, history.length);
    }

    final jsonList = history.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<List<SearchHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    try {
      return jsonList
          .map((j) => SearchHistory.fromJson(jsonDecode(j) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> deleteHistoryItem(SearchHistory item) async {
    final history = await getHistory();
    history.removeWhere(
      (h) => h.startStation.id == item.startStation.id && h.endStation.id == item.endStation.id,
    );

    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<void> savePlaceSearch(PlaceResult place) async {
    final history = await getPlaceHistory();
    history.removeWhere(
      (item) =>
          item.name.toLowerCase() == place.name.toLowerCase() ||
          (place.placeId != null && item.placeId == place.placeId),
    );
    history.insert(0, place);
    if (history.length > AppConstants.maxPlaceHistory) {
      history.removeRange(AppConstants.maxPlaceHistory, history.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _placeKey,
      history
          .map(
            (p) => jsonEncode({
              'name': p.name,
              'latitude': p.latitude,
              'longitude': p.longitude,
              'formattedAddress': p.formattedAddress,
              'placeId': p.placeId,
            }),
          )
          .toList(),
    );
  }

  Future<List<PlaceResult>> getPlaceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_placeKey) ?? [];
    try {
      return jsonList.map((raw) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return PlaceResult(
          name: json['name'] as String,
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
          formattedAddress: json['formattedAddress'] as String?,
          placeId: json['placeId'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deletePlaceHistoryItem(PlaceResult place) async {
    final history = await getPlaceHistory();
    history.removeWhere(
      (item) =>
          item.name.toLowerCase() == place.name.toLowerCase() ||
          (place.placeId != null && item.placeId == place.placeId),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _placeKey,
      history
          .map(
            (p) => jsonEncode({
              'name': p.name,
              'latitude': p.latitude,
              'longitude': p.longitude,
              'formattedAddress': p.formattedAddress,
              'placeId': p.placeId,
            }),
          )
          .toList(),
    );
  }

  Future<void> clearPlaceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_placeKey);
  }
}