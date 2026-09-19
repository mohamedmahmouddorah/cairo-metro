import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/metro_station.dart';
import '../../../data/models/route_result.dart';
import '../../../data/models/route_segment.dart';

class ResultView extends StatefulWidget {
  final RouteResult result;
  final MetroStation start;
  final MetroStation end;
  final List<RouteResult>? alternatives;

  const ResultView({
    super.key,
    required this.result,
    required this.start,
    required this.end,
    this.alternatives,
  });

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  late RouteResult _selectedRoute;

  @override
  void initState() {
    super.initState();
    _selectedRoute = widget.result;
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes < 60) {
      return '$totalMinutes دقيقة';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) {
      return '$hours ساعة';
    }

    return '$hours ساعة و $minutes دقائق';
  }

  Color _lineColor(int lineId) {
    switch (lineId) {
      case 1:
        return const Color(0xFF2563EB);
      case 2:
        return const Color(0xFFEF4444);
      case 3:
        return const Color(0xFF10B981);
      default:
        return Colors.blue;
    }
  }

  String _lineName(int lineId) {
    switch (lineId) {
      case 1:
        return 'الخط الأول';
      case 2:
        return 'الخط الثاني';
      case 3:
        return 'الخط الثالث';
      default:
        return 'خط $lineId';
    }
  }

  Future<void> _openStationOnMap(MetroStation station) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${station.latitude},${station.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayTime = _formatDuration(_selectedRoute.totalTimeMinutes);
    final allRoutes = [widget.result, ...?widget.alternatives];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تفاصيل الرحلة',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (allRoutes.length > 1) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: allRoutes.map((route) {
                      final isSelected = _selectedRoute == route;
                      final isFastest = route.transferCount <= widget.result.transferCount;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            isFastest ? 'المسار الأسرع (${route.totalTimeMinutes} د)' : 'أقل تحويلات (${route.transferCount} تحويلة)',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue,
                          backgroundColor: const Color(0xFF2A2D34),
                          onSelected: (_) {
                            setState(() {
                              _selectedRoute = route;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            // كارت ملخص الرحلة - تتحول الإحصائيات لشبكة مقسمة عند تضييق الشاشة
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D34),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 250;
                  final items = [
                    _SummaryItem(icon: Icons.timer, value: displayTime, label: 'الوقت'),
                    _SummaryItem(icon: Icons.route, value: '${_selectedRoute.stations.length} محطات', label: 'العدد'),
                    _SummaryItem(icon: Icons.swap_horiz, value: '${_selectedRoute.transferCount}', label: 'التحويلات'),
                    _SummaryItem(icon: Icons.money, value: '${_selectedRoute.fare} ج.م', label: 'التذكرة'),
                  ];

                  if (isNarrow) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceAround,
                      children: items.map((item) => SizedBox(width: constraints.maxWidth / 2 - 12, child: item)).toList(),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: items.map((e) => Expanded(child: e)).toList(),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 220;
                  final button = TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _openStationOnMap(widget.start),
                    icon: const Icon(Icons.map, color: Colors.blue, size: 16),
                    label: const Text(
                      'المحطة بالخريطة',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  );

                  final title = const Text(
                    'خط السير',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        title,
                        const SizedBox(height: 4),
                        Align(alignment: Alignment.centerLeft, child: button),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      button,
                      const Spacer(),
                      title,
                    ],
                  );
                },
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _selectedRoute.segments.length,
                itemBuilder: (context, segIndex) {
                  final segment = _selectedRoute.segments[segIndex];
                  final color = _lineColor(segment.lineId);
                  final lineName = _lineName(segment.lineId);

                  TransferInstruction? transferAfter;
                  if (segIndex < _selectedRoute.segments.length - 1) {
                    for (final t in _selectedRoute.transfers) {
                      if (t.station.id == segment.exitStation.id &&
                          t.fromLineId == segment.lineId) {
                        transferAfter = t;
                        break;
                      }
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'اتجاه ${segment.directionNameAr}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lineName,
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      ...segment.stations.asMap().entries.map((entry) {
                        final i = entry.key;
                        final station = entry.value;
                        final isFirst = i == 0;
                        final isLast = i == segment.stations.length - 1;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  station.nameAr,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: (isFirst || isLast) ? Colors.white : Colors.white70,
                                    fontSize: (isFirst || isLast) ? 14 : 12,
                                    fontWeight: (isFirst || isLast) ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Container(
                                  width: (isFirst || isLast) ? 12 : 8,
                                  height: (isFirst || isLast) ? 12 : 8,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                if (!isLast || segIndex < _selectedRoute.segments.length - 1)
                                  Container(
                                    width: 2,
                                    height: 22,
                                    color: color.withValues(alpha: 0.5),
                                  ),
                              ],
                            ),
                          ],
                        );
                      }),

                      if (transferAfter != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.swap_horiz, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'انزل ${transferAfter.station.nameAr} ➔ حوّل ${_lineName(transferAfter.toLineId)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
      ],
    );
  }
}