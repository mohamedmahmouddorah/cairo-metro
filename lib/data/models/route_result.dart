import 'metro_station.dart';
import 'route_preference.dart';
import 'route_segment.dart';

class RouteResult {
  final List<MetroStation> stations;
  final List<RouteSegment> segments;
  final List<TransferInstruction> transfers;
  final int totalTimeMinutes;
  final int transferCount;
  final int fare;
  final RoutePreference preferenceUsed;

  const RouteResult({
    required this.stations,
    required this.segments,
    required this.transfers,
    required this.totalTimeMinutes,
    required this.transferCount,
    required this.fare,
    required this.preferenceUsed,
  });

  String get stationSequenceKey => stations.map((s) => s.id).join('>');
}
