import 'route_preference.dart';
import 'route_result.dart';

class RoutingOutcome {
  final RouteResult primary;
  final List<RouteResult> alternatives;

  const RoutingOutcome({
    required this.primary,
    this.alternatives = const [],
  });
}

class RoutingRequest {
  final String startStationId;
  final String destinationStationId;
  final RoutePreference preference;

  const RoutingRequest({
    required this.startStationId,
    required this.destinationStationId,
    required this.preference,
  });
}
