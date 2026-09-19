import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/history_service.dart';
import '../../../core/services/location_service.dart'; 
import '../../../core/services/nearest_station_service.dart';
import '../../../core/services/places_service.dart';
import '../../../data/models/nearest_station_result.dart';
import '../../../data/models/place_result.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/place_search_controller.dart';

class PlaceSearchView extends StatefulWidget {
  const PlaceSearchView({super.key});

  @override
  State<PlaceSearchView> createState() => _PlaceSearchViewState();
}

class _PlaceSearchViewState extends State<PlaceSearchView> {
  late final TextEditingController _textController;
  late final PlaceSearchController controller;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    controller = Get.put(
      PlaceSearchController(
        placesService: Get.find<PlacesService>(),
        nearestStationService: Get.find<NearestStationService>(),
        historyService: Get.find<HistoryService>(),
        locationService: Get.find<LocationService>(), 
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    Get.delete<PlaceSearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        title: const Text('ابحث عن مكان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              onChanged: controller.onQueryChanged,
              onSubmitted: (_) => controller.submitTypedQuery(),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'مثال: المتحف المصري ,شارع عباس العقاد...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.blue),
                  onPressed: controller.useCurrentLocation, // زر تحديد موقعي الحالي مباشر
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: controller.submitTypedQuery,
                ),
                filled: true,
                fillColor: const Color(0xFF2A2D34),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isResolving.value) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('جاري تحديد أقرب محطة مترو...', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }

                final place = controller.selectedPlace.value;
                final nearest = controller.nearest.value;
                if (place != null && nearest != null) {
                  return _SelectedPlaceCard(
                    place: place,
                    nearest: nearest,
                    warningMessage: controller.outOfCoverageWarning.value,
                    onOpenMap: controller.openPlaceOnMap,
                    onUseStart: () {
                      Get.find<HomeController>().applyPlaceAsStation(place, nearest, asStart: true);
                      Get.back();
                    },
                    onUseEnd: () {
                      Get.find<HomeController>().applyPlaceAsStation(place, nearest, asStart: false);
                      Get.back();
                    },
                  );
                }

                if (controller.isSearching.value) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('جاري البحث...', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }

                if (controller.suggestions.isNotEmpty) {
                  return ListView.builder(
                    itemCount: controller.suggestions.length,
                    itemBuilder: (context, index) {
                      final item = controller.suggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.place, color: Colors.blue),
                        title: Text(item.primaryText, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 15)),
                        subtitle: item.secondaryText == null
                            ? null
                            : Text(item.secondaryText!, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        onTap: () => controller.selectSuggestion(item),
                      );
                    },
                  );
                }

                if (controller.placeHistory.isNotEmpty) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: controller.clearHistory,
                            child: const Text('مسح الكل', style: TextStyle(color: Colors.redAccent)),
                          ),
                          const Text('عمليات البحث الأخيرة', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(color: Colors.white24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.placeHistory.length,
                          itemBuilder: (context, index) {
                            final item = controller.placeHistory[index];
                            return ListTile(
                              leading: const Icon(Icons.history, color: Colors.white54),
                              title: Text(item.name, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 15)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () async {
                                  controller.placeHistory.removeAt(index);
                                },
                              ),
                              onTap: () => controller.selectHistory(item),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: Text(
                    'ابحث عن مكان حقيقي لتحديد أقرب محطة مترو له.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  const _SelectedPlaceCard({
    required this.place,
    required this.nearest,
    this.warningMessage,
    required this.onOpenMap,
    required this.onUseStart,
    required this.onUseEnd,
  });

  final PlaceResult place;
  final NearestStationResult nearest;
  final String? warningMessage;
  final VoidCallback onOpenMap;
  final VoidCallback onUseStart;
  final VoidCallback onUseEnd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D34),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('📍 ${place.name}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (place.formattedAddress != null) ...[
                const SizedBox(height: 6),
                Text(place.formattedAddress!, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
              const SizedBox(height: 16),

              if (warningMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amberAccent.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warningMessage!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text('أقرب محطة مترو متاحة', textAlign: TextAlign.right, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text('🚇 ${nearest.station.nameAr}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(nearest.station.nameEn, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 8),
              Text(nearest.distanceLabelAr, textAlign: TextAlign.right, style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onOpenMap,
                icon: const Icon(Icons.map, color: Colors.blue),
                label: const Text('عرض الموقع على الخريطة', style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
                      onPressed: onUseStart,
                      child: const Text('استخدم كبداية', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: onUseEnd,
                      child: const Text('استخدم كوجهة', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}