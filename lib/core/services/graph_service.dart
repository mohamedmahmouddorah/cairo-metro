
import '../app_constants.dart';
import '../../data/metro_data.dart';
import '../../data/models/line_station.dart';
import '../../data/models/metro_station.dart';
import '../../data/models/route_preference.dart';
import '../../data/models/route_result.dart';
import '../../data/models/route_segment.dart';
import '../../data/models/routing_outcome.dart';

class StationNode {
  final String stationId;
  final int lineId;

  const StationNode(this.stationId, this.lineId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationNode && stationId == other.stationId && lineId == other.lineId;

  @override
  int get hashCode => Object.hash(stationId, lineId);
}

class Edge {
  final StationNode target;
  final double weight;
  final bool isTransfer;

  const Edge(this.target, this.weight, {this.isTransfer = false});
}

/// Engine محلي مستقل لحساب مسارات المترو بأعلى كفاءة وأداء
class GraphService {
  final Map<StationNode, List<Edge>> _adjList = {};
  
  // 🟢 ثوابت الوقت الصافي المعتمدة: 2 دقيقة للمحطة و5 دقائق للتحويلة
  static const double _timeBetweenStations = 2.0;
  static const double _transferPenalty = 5.0;
  static const double _transferPenaltyHigh = 1000.0;

  /// دالة تحويل الدقائق إلى ساعات ودقائق
String formatDuration(int totalMinutes) {
  if (totalMinutes < 60) {
    return '$totalMinutes دقيقة';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (minutes == 0) {
    return '$hours ساعة';
  }

  return '$hours ساعة و $minutes دقيقة';
}

  GraphService() {
    _buildGraph();
  }

  void _buildGraph() {
    _buildLineEdges(MetroData.line1Stations, 1);
    _buildLineEdges(MetroData.line2Stations, 2);
    _buildLine3Edges(MetroData.line3Stations, 3);
    _buildTransferEdges();
  }

  void _buildLineEdges(List<LineStation> lineStations, int lineId) {
    final sorted = List<LineStation>.from(lineStations)..sort((a, b) => a.order.compareTo(b.order));
    for (var i = 0; i < sorted.length - 1; i++) {
      final current = StationNode(sorted[i].stationId, lineId);
      final next = StationNode(sorted[i + 1].stationId, lineId);
      _addEdge(current, next, _timeBetweenStations);
      _addEdge(next, current, _timeBetweenStations);
    }
  }

  void _buildLine3Edges(List<LineStation> lineStations, int lineId) {
    final trunk = lineStations.where((s) => s.branchId == null).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final nwBranch = lineStations.where((s) => s.branchId == 'nw').toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final swBranch = lineStations.where((s) => s.branchId == 'sw').toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    for (var i = 0; i < trunk.length - 1; i++) {
      final current = StationNode(trunk[i].stationId, lineId);
      final next = StationNode(trunk[i + 1].stationId, lineId);
      _addEdge(current, next, _timeBetweenStations);
      _addEdge(next, current, _timeBetweenStations);
    }

    final forkNode = StationNode(trunk.last.stationId, lineId);

    if (nwBranch.isNotEmpty) {
      final firstNw = StationNode(nwBranch.first.stationId, lineId);
      _addEdge(forkNode, firstNw, _timeBetweenStations);
      _addEdge(firstNw, forkNode, _timeBetweenStations);
      for (var i = 0; i < nwBranch.length - 1; i++) {
        final current = StationNode(nwBranch[i].stationId, lineId);
        final next = StationNode(nwBranch[i + 1].stationId, lineId);
        _addEdge(current, next, _timeBetweenStations);
        _addEdge(next, current, _timeBetweenStations);
      }
    }

    if (swBranch.isNotEmpty) {
      final firstSw = StationNode(swBranch.first.stationId, lineId);
      _addEdge(forkNode, firstSw, _timeBetweenStations);
      _addEdge(firstSw, forkNode, _timeBetweenStations);
      for (var i = 0; i < swBranch.length - 1; i++) {
        final current = StationNode(swBranch[i].stationId, lineId);
        final next = StationNode(swBranch[i + 1].stationId, lineId);
        _addEdge(current, next, _timeBetweenStations);
        _addEdge(next, current, _timeBetweenStations);
      }
    }
  }

  void _buildTransferEdges() {
    for (final station in MetroData.stations) {
      if (station.lineIds.length <= 1) continue;
      for (var i = 0; i < station.lineIds.length; i++) {
        for (var j = i + 1; j < station.lineIds.length; j++) {
          final nodeA = StationNode(station.id, station.lineIds[i]);
          final nodeB = StationNode(station.id, station.lineIds[j]);
          _addEdge(nodeA, nodeB, _transferPenalty, isTransfer: true);
          _addEdge(nodeB, nodeA, _transferPenalty, isTransfer: true);
        }
      }
    }
  }

  void _addEdge(StationNode from, StationNode to, double weight, {bool isTransfer = false}) {
    _adjList.putIfAbsent(from, () => []).add(Edge(to, weight, isTransfer: isTransfer));
  }

  RoutingOutcome? calculateRoutes(RoutingRequest request) {
    if (request.startStationId == request.destinationStationId) return null;

    final fastest = calculateRoute(
      request.startStationId,
      request.destinationStationId,
      preference: RoutePreference.fastest,
    );
    final fewest = calculateRoute(
      request.startStationId,
      request.destinationStationId,
      preference: RoutePreference.fewestTransfers,
    );
    final balanced = calculateRoute(
      request.startStationId,
      request.destinationStationId,
    );

    final byPreference = switch (request.preference) {
      RoutePreference.fastest => fastest,
      RoutePreference.fewestTransfers => fewest,
    };

    final primary = byPreference ?? fastest ?? fewest ?? balanced;
    if (primary == null) return null;

    final alternatives = <RouteResult>[];
    for (final candidate in [fastest, fewest, balanced]) {
      if (candidate == null) continue;
      if (candidate.stationSequenceKey == primary.stationSequenceKey) continue;
      final duplicate = alternatives.any((a) => a.stationSequenceKey == candidate.stationSequenceKey);
      if (!duplicate) alternatives.add(candidate);
    }

    return RoutingOutcome(primary: primary, alternatives: alternatives);
  }
RouteResult? calculateRoute(
    String startStationId,
    String endStationId, {
    bool leastTransfers = false,
    RoutePreference? preference,
  }) {
    if (startStationId == endStationId) return null;

    final resolvedPreference = preference ??
        (leastTransfers ? RoutePreference.fewestTransfers : RoutePreference.fastest);

    final startStation = MetroData.stationById(startStationId);
    final endStation = MetroData.stationById(endStationId);
    if (startStation == null || endStation == null) return null;

    final startNodes = startStation.lineIds.map((l) => StationNode(startStationId, l)).toList();
    final endNodes = endStation.lineIds.map((l) => StationNode(endStationId, l)).toSet();

    final distances = <StationNode, double>{};
    final previous = <StationNode, StationNode?>{};
    
    final pq = <_QueueNode>[];

    for (final node in _adjList.keys) {
      distances[node] = double.infinity;
    }

    for (final sn in startNodes) {
      distances[sn] = 0.0;
      pq.add(_QueueNode(sn, 0.0));
    }

    while (pq.isNotEmpty) {
      pq.sort((a, b) => a.distance.compareTo(b.distance));
      final current = pq.removeAt(0);

      if (endNodes.contains(current.node)) {
        return _buildRouteResult(previous, current.node, resolvedPreference);
      }

      if (current.distance > (distances[current.node] ?? double.infinity)) continue;

      for (final edge in _adjList[current.node] ?? const <Edge>[]) {
        var penalty = edge.weight;
        if (edge.isTransfer) {
          penalty = switch (resolvedPreference) {
            RoutePreference.fastest => _transferPenalty,
            RoutePreference.fewestTransfers => _transferPenaltyHigh,
          };
        }

        final newDist = (distances[current.node] ?? double.infinity) + penalty;
        if (newDist < (distances[edge.target] ?? double.infinity)) {
          distances[edge.target] = newDist;
          previous[edge.target] = current.node;
          pq.add(_QueueNode(edge.target, newDist));
        }
      }
    }

    return null;
  }
  RouteResult _buildRouteResult(
    Map<StationNode, StationNode?> previous,
    StationNode endNode,
    RoutePreference preference,
  ) {
    final path = <StationNode>[];
    StationNode? curr = endNode;
    while (curr != null) {
      path.add(curr);
      curr = previous[curr];
    }
    path.replaceRange(0, path.length, path.reversed.toList());

    final resultStations = <MetroStation>[];
    var transfers = 0;
    var totalTime = 0;

    for (var i = 0; i < path.length; i++) {
      final node = path[i];
      if (i > 0) {
        final prevNode = path[i - 1];
        if (prevNode.stationId == node.stationId) {
          transfers++;
          totalTime += _transferPenalty.toInt(); // 5 دقائق لكل تحويلة
        } else {
          totalTime += _timeBetweenStations.toInt(); // 2 دقيقة لكل محطة
        }
      }

      if (i == 0 || path[i - 1].stationId != node.stationId) {
        final station = MetroData.stationById(node.stationId);
        if (station != null) resultStations.add(station);
      }
    }

    final segments = _buildSegments(path);
    final transferInstructions = _buildTransferInstructions(path, segments);

    return RouteResult(
      stations: resultStations,
      segments: segments,
      transfers: transferInstructions,
      totalTimeMinutes: totalTime,
      transferCount: transfers + transferInstructions.where((t) => t.sameLineBranchChange).length,
      fare: FareCalculator.calculateFare(resultStations.length),
      preferenceUsed: preference,
    );
  }

  List<RouteSegment> _buildSegments(List<StationNode> path) {
    if (path.isEmpty) return const [];

    final segments = <RouteSegment>[];
    var currentLine = path.first.lineId;
    var currentStations = <String>[path.first.stationId];
    String? currentBranch = MetroData.branchIdFor(path.first.stationId, currentLine);

    void closeSegment() {
      if (currentStations.isEmpty) return;
      final unique = <String>[];
      for (final id in currentStations) {
        if (unique.isEmpty || unique.last != id) unique.add(id);
      }
      final stations = unique.map(MetroData.stationById).whereType<MetroStation>().toList();
      if (stations.length < 2 && stations.isNotEmpty) {
        currentStations = [];
        return;
      }
      if (stations.isEmpty) {
        currentStations = [];
        return;
      }
      final direction = _directionFor(currentLine, stations.first.id, stations.last.id);
      segments.add(
        RouteSegment(
          lineId: currentLine,
          directionNameEn: direction.$1,
          directionNameAr: direction.$2,
          boardingStation: stations.first,
          exitStation: stations.last,
          stations: stations,
        ),
      );
      currentStations = [];
    }

    for (var i = 1; i < path.length; i++) {
      final prev = path[i - 1];
      final node = path[i];
      final nodeBranch = MetroData.branchIdFor(node.stationId, node.lineId);
      final branchSwitch = prev.lineId == 3 &&
          node.lineId == 3 &&
          currentBranch != null &&
          nodeBranch != null &&
          currentBranch != nodeBranch;

      if (prev.stationId == node.stationId && prev.lineId != node.lineId) {
        closeSegment();
        currentLine = node.lineId;
        currentStations = [node.stationId];
        currentBranch = MetroData.branchIdFor(node.stationId, currentLine);
        continue;
      }

      if (branchSwitch) {
        currentStations.add(prev.stationId == 'l3_kit_kat' ? prev.stationId : 'l3_kit_kat');
        if (!currentStations.contains(prev.stationId)) {
          currentStations.add(prev.stationId);
        }
        closeSegment();
        currentLine = node.lineId;
        currentStations = [prev.stationId, node.stationId];
        currentBranch = nodeBranch;
        continue;
      }

      currentStations.add(node.stationId);
      currentBranch = nodeBranch ?? currentBranch;
    }

    closeSegment();
    return segments;
  }

  List<TransferInstruction> _buildTransferInstructions(
    List<StationNode> path,
    List<RouteSegment> segments,
  ) {
    final instructions = <TransferInstruction>[];

    for (var i = 1; i < path.length; i++) {
      final prev = path[i - 1];
      final node = path[i];
      if (prev.stationId == node.stationId && prev.lineId != node.lineId) {
        RouteSegment? nextSegment;
        for (final segment in segments) {
          if (segment.boardingStation.id == node.stationId && segment.lineId == node.lineId) {
            nextSegment = segment;
            break;
          }
        }
        final station = MetroData.stationById(node.stationId);
        if (station == null) continue;
        instructions.add(
          TransferInstruction(
            station: station,
            fromLineId: prev.lineId,
            toLineId: node.lineId,
            nextDirectionEn: nextSegment?.directionNameEn ?? '',
            nextDirectionAr: nextSegment?.directionNameAr ?? '',
          ),
        );
      }
    }

    for (var i = 0; i < segments.length - 1; i++) {
      final a = segments[i];
      final b = segments[i + 1];
      if (a.lineId == b.lineId && a.lineId == 3 && a.exitStation.id == b.boardingStation.id) {
        final already = instructions.any((t) => t.station.id == a.exitStation.id && t.toLineId == b.lineId);
        if (!already) {
          instructions.add(
            TransferInstruction(
              station: a.exitStation,
              fromLineId: a.lineId,
              toLineId: b.lineId,
              nextDirectionEn: b.directionNameEn,
              nextDirectionAr: b.directionNameAr,
              sameLineBranchChange: true,
            ),
          );
        }
      }
    }

    return instructions;
  }

  (String, String) _directionFor(int lineId, String fromId, String toId) {
    switch (lineId) {
      case 1:
        final from = _orderOnLine(MetroData.line1Stations, fromId);
        final to = _orderOnLine(MetroData.line1Stations, toId);
        if (from != null && to != null && to < from) {
          return ('Helwan', 'حلوان');
        }
        return ('New El-Marg', 'المرج الجديدة');
      case 2:
        final from = _orderOnLine(MetroData.line2Stations, fromId);
        final to = _orderOnLine(MetroData.line2Stations, toId);
        if (from != null && to != null && to < from) {
          return ('Shubra El-Kheima', 'شبرا الخيمة');
        }
        return ('El-Mounib', 'المنيب');
      case 3:
        return _line3Direction(fromId, toId);
      default:
        final line = MetroData.lineById(lineId);
        return (line?.nameEn ?? 'Metro', line?.nameAr ?? 'مترو');
    }
  }

  (String, String) _line3Direction(String fromId, String toId) {
    final toBranch = MetroData.branchIdFor(toId, 3);
    final fromBranch = MetroData.branchIdFor(fromId, 3);
    final fromOrder = _line3ComparableOrder(fromId);
    final toOrder = _line3ComparableOrder(toId);

    if (toBranch == 'nw' && fromBranch != 'nw') {
      return ('Rod El Farag Corridor', 'محور روض الفرج');
    }
    if (toBranch == 'sw' && fromBranch != 'sw') {
      return ('Cairo University', 'جامعة القاهرة');
    }
    if (fromBranch == 'nw' && toBranch != 'nw') {
      return ('Adly Mansour', 'عدلي منصور');
    }
    if (fromBranch == 'sw' && toBranch != 'sw') {
      return ('Adly Mansour', 'عدلي منصور');
    }
    if (fromOrder != null && toOrder != null && toOrder < fromOrder) {
      return ('Adly Mansour', 'عدلي منصور');
    }
    if (toBranch == 'nw' || fromBranch == 'nw') {
      return ('Rod El Farag Corridor', 'محور روض الفرج');
    }
    if (toBranch == 'sw' || fromBranch == 'sw') {
      return ('Cairo University', 'جامعة القاهرة');
    }
    return ('Adly Mansour', 'عدلي منصور');
  }

  int? _orderOnLine(List<LineStation> stations, String stationId) {
    for (final item in stations) {
      if (item.stationId == stationId) return item.order;
    }
    return null;
  }

  int? _line3ComparableOrder(String stationId) {
    for (final item in MetroData.line3Stations) {
      if (item.stationId == stationId) {
        if (item.branchId == 'nw') return 100 + item.order;
        if (item.branchId == 'sw') return 200 + item.order;
        return item.order;
      }
    }
    return null;
  }
}

class _QueueNode {
  final StationNode node;
  final double distance;
  _QueueNode(this.node, this.distance);
}