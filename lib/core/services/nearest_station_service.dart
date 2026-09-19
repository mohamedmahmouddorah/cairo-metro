import 'package:geolocator/geolocator.dart';

import '../../data/metro_data.dart';
import '../../data/models/metro_station.dart';
import '../../data/models/nearest_station_result.dart';
import '../../data/models/station_entrance.dart';
import '../errors/app_failure.dart';
import 'places_service.dart';

class NearestStationService {
  NearestStationService({PlacesService? placesService})
      : _placesService = placesService;

  final PlacesService? _placesService;

  /// دالة إيجاد أقرب محطة مترو مع التصفية الجغرافية بدقة وحساب الأبعاد
  Future<NearestStationResult> findNearest({
    required double latitude,
    required double longitude,
  }) async {
    MetroStation? closest;
    StationEntrance? closestEntrance;
    var minDistance = double.infinity;

    // حلقة تكرارية سريعة بأقل تعقيد زمني O(N) لحساب الأبعاد بدقة
    for (final station in MetroData.stations) {
      // حساب المسافة للمحطة الرئيسية
      final stationDistance = Geolocator.distanceBetween(
        latitude,
        longitude,
        station.latitude,
        station.longitude,
      );

      if (stationDistance < minDistance) {
        minDistance = stationDistance;
        closest = station;
        closestEntrance = null;
      }

      // حساب المسافة لأبواب ودخلات المحطة إن وجدت لضمان أعلى دقة
      for (final entrance in station.entrances) {
        final entranceDistance = Geolocator.distanceBetween(
          latitude,
          longitude,
          entrance.latitude,
          entrance.longitude,
        );

        if (entranceDistance < minDistance) {
          minDistance = entranceDistance;
          closest = station;
          closestEntrance = entrance;
        }
      }
    }

    if (closest == null) {
      throw AppFailure.noNearbyStation;
    }

    var mode = DistanceMode.geographical;
    var distance = minDistance;

    // محاولة جلب مسافة المشي الحقيقية لأقرب 3 محطات إذا كانت خدمة Google متوفرة
    final walking = await _tryWalkingAmongClosest(latitude, longitude);
    if (walking != null) {
      closest = walking.station;
      closestEntrance = walking.entrance;
      distance = walking.distanceMeters;
      mode = walking.distanceMode;
    }

    return NearestStationResult(
      station: closest,
      distanceMeters: distance,
      distanceMode: mode,
      entrance: closestEntrance,
    );
  }

  /// حساب مسافات المشي المباشرة لأقرب 3 محطات فقط لترشيد استهلاك الذاكرة والشبكة
  Future<NearestStationResult?> _tryWalkingAmongClosest(
      double lat, double lng) async {
    final places = _placesService;
    if (places == null || !places.usesGooglePlaces) return null;

    final ranked = MetroData.stations.map((station) {
      final geo = Geolocator.distanceBetween(
          lat, lng, station.latitude, station.longitude);
      return (station: station, geoDistance: geo);
    }).toList(growable: false);

    final sortedList = List.of(ranked)
      ..sort((a, b) => a.geoDistance.compareTo(b.geoDistance));

    final topThree = sortedList.take(3);
    NearestStationResult? bestResult;

    for (final item in topThree) {
      final meters = await places.walkingDistanceMeters(
        originLat: lat,
        originLng: lng,
        destLat: item.station.latitude,
        destLng: item.station.longitude,
      );

      if (meters == null) continue;

      if (bestResult == null || meters < bestResult.distanceMeters) {
        bestResult = NearestStationResult(
          station: item.station,
          distanceMeters: meters.toDouble(),
          distanceMode: DistanceMode.walking,
        );
      }
    }

    return bestResult;
  }
}