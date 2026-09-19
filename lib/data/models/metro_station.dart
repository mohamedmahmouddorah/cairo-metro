import 'package:flutter/foundation.dart';
import 'station_entrance.dart';

@immutable
class MetroStation {
  final String id;
  final String nameEn;
  final String nameAr;
  final double latitude;
  final double longitude;
  final List<int> lineIds;
  final List<StationEntrance> entrances;

  const MetroStation({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.latitude,
    required this.longitude,
    required this.lineIds,
    this.entrances = const [],
  });

  bool get isInterchange => lineIds.length > 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetroStation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}