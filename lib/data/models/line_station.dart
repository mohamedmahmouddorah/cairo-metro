class LineStation {
  final String stationId;
  final int order;
  final String? branchId; // null for trunk, 'nw' or 'sw' for branches

  const LineStation({
    required this.stationId,
    required this.order,
    this.branchId,
  });
}
