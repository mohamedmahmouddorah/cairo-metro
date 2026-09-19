import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/metro_station.dart';
import '../controllers/home_controller.dart';
import 'widgets/station_search_dialog.dart';
import '../../places/views/map_picker_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _openStationDirectionOnMap(double lat, double lng) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo1.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.directions_subway, color: Colors.blue, size: 28);
              },
            ),
            const SizedBox(height: 2),
            const Text(
              'مترو الأنفاق',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white, size: 24),
            onPressed: () => _showHistorySheet(context, controller),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ActionButton(
                icon: Icons.my_location,
                label: 'تحديد أقرب محطة مترو لموقعي الحالي',
                onTap: () => controller.findNearestStartStation(),
                isLoading: controller.isLocatingStart,
              ),
              const SizedBox(height: 10),

              _ActionButton(
                icon: Icons.map,
                label: 'البحث عن مكان على الخريطة (مثل عباس العقاد)',
                onTap: () => Get.to(() => const MapPickerView()),
              ),
              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerRight,
                child: Text('محطة البداية', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              _StationSelector(
                station: controller.startStation,
                onTap: () async {
                  controller.selectedLineFilter.value = 0;
                  final selected = await Get.dialog<MetroStation>(const StationSearchDialog());
                  if (selected != null) {
                    controller.startStation.value = selected;
                    controller.startPlaceLabel.value = null;
                  }
                },
                placeName: controller.startPlaceLabel,
              ),
              const SizedBox(height: 6),

              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D34),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert, color: Colors.blue, size: 24),
                    onPressed: () {
                      final temp = controller.startStation.value;
                      controller.startStation.value = controller.endStation.value;
                      controller.endStation.value = temp;

                      final tempPlace = controller.startPlaceLabel.value;
                      controller.startPlaceLabel.value = controller.endPlaceLabel.value;
                      controller.endPlaceLabel.value = tempPlace;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),

              const Align(
                alignment: Alignment.centerRight,
                child: Text('محطة الوصول', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              _StationSelector(
                station: controller.endStation,
                onTap: () async {
                  controller.selectedLineFilter.value = 0;
                  final selected = await Get.dialog<MetroStation>(const StationSearchDialog());
                  if (selected != null) {
                    controller.endStation.value = selected;
                    controller.endPlaceLabel.value = null;
                  }
                },
                placeName: controller.endPlaceLabel,
              ),
              const SizedBox(height: 10),

              // كارت أقرب محطة مترو - ينسق عناصر أفقياً أو رأسياً حسب عرض الشاشة
              Obx(() {
                final nearest = controller.nearestStationInfo.value;
                if (nearest == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D34),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 260;
                      final buttonWidget = TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _openStationDirectionOnMap(
                          nearest.station.latitude,
                          nearest.station.longitude,
                        ),
                        icon: const Icon(Icons.map, color: Colors.blue, size: 14),
                        label: const Text(
                          'المحطة بالخريطة',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      );

                      final textWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('أقرب محطة مترو', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            nearest.station.nameAr,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            nearest.station.nameEn,
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          Text(
                            nearest.distanceLabelAr,
                            style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            textWidget,
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: buttonWidget,
                            ),
                          ],
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: buttonWidget),
                          const SizedBox(width: 8),
                          Expanded(child: textWidget),
                        ],
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),

              const Align(
                alignment: Alignment.centerRight,
                child: Text('تفضيل المسار', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ),
              const SizedBox(height: 6),
              
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _PreferenceChip(
                      label: 'الأسرع',
                      selected: !controller.leastTransfers.value,
                      onTap: () => controller.leastTransfers.value = false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PreferenceChip(
                      label: 'أقل تحويلات',
                      selected: controller.leastTransfers.value,
                      onTap: () => controller.leastTransfers.value = true,
                    ),
                  ),
                ],
              )),
              
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => controller.calculateRoute(),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('احسب الرحلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistorySheet(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.clearHistory();
                      Get.back();
                    },
                    child: const Text('مسح الكل', style: TextStyle(color: Colors.redAccent)),
                  ),
                  const Text('سجل الرحلات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: Obx(() {
                if (controller.historyList.isEmpty) {
                  return const Center(child: Text('لا يوجد سجل بحث سابق', style: TextStyle(color: Colors.white54)));
                }
                return ListView.builder(
                  itemCount: controller.historyList.length,
                  itemBuilder: (context, index) {
                    final item = controller.historyList[index];
                    return ListTile(
                      title: Text('${item.startStation.nameAr} ➔ ${item.endStation.nameAr}', style: const TextStyle(color: Colors.white, fontSize: 15)),
                      subtitle: Text(item.date.toString().substring(0, 16), style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => controller.deleteSingleHistory(item),
                      ),
                      onTap: () {
                        controller.startStation.value = item.startStation;
                        controller.endStation.value = item.endStation;
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final RxBool? isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2D34),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              isLoading != null
                  ? Obx(() => isLoading!.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(icon, color: Colors.blue, size: 20))
                  : Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StationSelector extends StatelessWidget {
  final Rxn<MetroStation> station;
  final VoidCallback onTap;
  final RxnString? placeName;

  const _StationSelector({
    required this.station,
    required this.onTap,
    this.placeName,
  });

  Widget _buildLineBadges(List<int> lineIds) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: lineIds.map((id) {
        Color color = Colors.grey;
        if (id == 1) color = const Color(0xFF2563EB);
        if (id == 2) color = const Color(0xFFEF4444);
        if (id == 3) color = const Color(0xFF10B981);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          ),
          child: Text(
            'L$id',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D34),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isVeryNarrow = constraints.maxWidth < 180;

            final badgesWidget = Obx(() {
              final s = station.value;
              if (s == null) return const SizedBox.shrink();
              return _buildLineBadges(s.lineIds);
            });

            final detailsWidget = Obx(() {
              final s = station.value;
              if (s == null) {
                return const Text('اختر المحطة...', textAlign: TextAlign.right, style: TextStyle(color: Colors.white54));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.nameAr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    s.nameEn,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  if (placeName != null)
                    Obx(() {
                      final name = placeName!.value;
                      if (name == null) return const SizedBox.shrink();
                      return Text(
                        name,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
                      );
                    }),
                ],
              );
            });

            if (isVeryNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  detailsWidget,
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: badgesWidget,
                  ),
                ],
              );
            }

            return Row(
              children: [
                badgesWidget,
                const SizedBox(width: 8),
                Expanded(child: detailsWidget),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PreferenceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withValues(alpha: 0.2) : const Color(0xFF2A2D34),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.blue : Colors.white12,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label.trim(),
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, color: Colors.blue, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}