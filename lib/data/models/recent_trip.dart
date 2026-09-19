import 'route_preference.dart';

enum TripSearchSource { station, place, location }

class RecentTrip {
  final String startStationId;
  final String destinationStationId;
  final RoutePreference preference;
  final String routeType;
  final TripSearchSource searchSource;
  final String? placeName;
  final DateTime timestamp;

  const RecentTrip({
    required this.startStationId,
    required this.destinationStationId,
    required this.preference,
    required this.searchSource,
    required this.timestamp,
    this.routeType = 'metro',
    this.placeName,
  });

  Map<String, dynamic> toJson() => {
        'startStationId': startStationId,
        'destinationStationId': destinationStationId,
        'preference': preference.name,
        'routeType': routeType,
        'searchSource': searchSource.name,
        'placeName': placeName,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RecentTrip.fromJson(Map<String, dynamic> json) {
    return RecentTrip(
      startStationId: json['startStationId'] as String,
      destinationStationId: json['destinationStationId'] as String,
      preference: RoutePreference.values.firstWhere(
        (p) => p.name == json['preference'],
        orElse: () => RoutePreference.fastest,
      ),
      routeType: json['routeType'] as String? ?? 'metro',
      searchSource: TripSearchSource.values.firstWhere(
        (s) => s.name == json['searchSource'],
        orElse: () => TripSearchSource.station,
      ),
      placeName: json['placeName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
