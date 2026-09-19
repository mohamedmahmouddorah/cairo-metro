import 'metro_station.dart';
import 'station_entrance.dart';

enum DistanceMode { geographical, walking }

class NearestStationResult {
  final MetroStation station;
  final double distanceMeters;
  final DistanceMode distanceMode;
  final StationEntrance? entrance;

  const NearestStationResult({
    required this.station,
    required this.distanceMeters,
    required this.distanceMode,
    this.entrance,
  });

  String get distanceLabelAr {
    final meters = distanceMeters.round();
    if (meters >= 1000) {
      final km = (distanceMeters / 1000).toStringAsFixed(1);
      return distanceMode == DistanceMode.walking
          ? 'مسافة المشي تقريباً $km كم'
          : 'المسافة تقريباً $km كم';
    }
    return distanceMode == DistanceMode.walking
        ? 'مسافة المشي تقريباً $meters م'
        : 'المسافة تقريباً $meters م';
  }
}
