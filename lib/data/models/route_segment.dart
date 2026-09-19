import 'metro_station.dart';

class RouteSegment {
  final int lineId;
  final String directionNameEn;
  final String directionNameAr;
  final MetroStation boardingStation;
  final MetroStation exitStation;
  final List<MetroStation> stations;

  const RouteSegment({
    required this.lineId,
    required this.directionNameEn,
    required this.directionNameAr,
    required this.boardingStation,
    required this.exitStation,
    required this.stations,
  });
}

class TransferInstruction {
  final MetroStation station;
  final int fromLineId;
  final int toLineId;
  final String nextDirectionEn;
  final String nextDirectionAr;
  final bool sameLineBranchChange;

  const TransferInstruction({
    required this.station,
    required this.fromLineId,
    required this.toLineId,
    required this.nextDirectionEn,
    required this.nextDirectionAr,
    this.sameLineBranchChange = false,
  });
}
