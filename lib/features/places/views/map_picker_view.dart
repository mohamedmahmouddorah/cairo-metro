import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import '../../../core/services/nearest_station_service.dart';
import '../../../core/services/places_service.dart';
import '../../../data/metro_data.dart';
import '../../../data/models/metro_station.dart';
import '../../../data/models/nearest_station_result.dart';
import '../../../data/models/place_result.dart';
import '../../home/controllers/home_controller.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  final NearestStationService _nearestStationService = Get.find<NearestStationService>();
  final PlacesService _placesService = Get.find<PlacesService>();
  final HomeController _homeController = Get.find<HomeController>();

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // مركز وسط البلد / القاهرة كإحداثيات افتراضية لفتح الخريطة فقط دون تحديد محطة مسبقة
  final lat_lng.LatLng _defaultCenter = const lat_lng.LatLng(30.0444, 31.2357);

  lat_lng.LatLng? _selectedLatLng;
  NearestStationResult? _nearestStationResult;
  PlaceResult? _selectedPlace;
  bool _isLoading = false; // تبدأ false لكي لا تعرض لودينغ أو محطة افتراضية عند الفتح

  @override
  void initState() {
    super.initState();
    // تم إلغاء _getUserCurrentLocation() تماماً من هنا لكي تفتح الخريطة نظيفة بدون أي تحديد مسبق أو محطة افتراضية مثل السادات
  }

  /// تحديد لون الدائرة بحسب الخط التابع له المحطة
  Color _getStationColor(MetroStation station) {
    if (station.lineIds.contains(1)) {
      return const Color(0xFF2563EB); // أزرق للخط الأول
    } else if (station.lineIds.contains(2)) {
      return const Color(0xFFEF4444); // أحمر للخط الثاني
    } else if (station.lineIds.contains(3)) {
      return const Color(0xFF10B981); // أخضر للخط الثالث
    }
    return Colors.grey;
  }

  /// دالة معالجة تحديد النقطة على الخريطة لحساب أقرب محطة مترو
  Future<void> _onPointSelected(lat_lng.LatLng latLng, {String? placeName}) async {
    setState(() {
      _selectedLatLng = latLng;
      _isLoading = true;
    });

    try {
      final nearest = await _nearestStationService.findNearest(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );

      setState(() {
        _nearestStationResult = nearest;
        _selectedPlace = PlaceResult(
          name: placeName ?? 'موقع على الخريطة',
          latitude: latLng.latitude,
          longitude: latLng.longitude,
        );
      });
    } catch (_) {
      // تجاهل الأخطاء الصامتة
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// دالة البحث عن مكان داخل الخريطة
  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final results = await _placesService.geocodeQuery(query);
      if (results.isNotEmpty) {
        final place = results.first;
        final newLatLng = lat_lng.LatLng(place.latitude, place.longitude);

        _mapController.move(newLatLng, 15.0);
        await _onPointSelected(newLatLng, placeName: place.name);
      }
    } catch (_) {
      // تجاهل الأخطاء الصامتة
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applySelection({required bool asStart}) {
    if (_nearestStationResult != null && _selectedPlace != null) {
      _homeController.applyPlaceAsStation(
        _selectedPlace!,
        _nearestStationResult!,
        asStart: asStart,
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('ابحث عن مكان على الخريطة', style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // 1. الخريطة التفاعلية مع رسم الدوائر الملونة للمحطات
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13.0,
              onTap: (tapPosition, point) => _onPointSelected(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cairometro.app',
              ),

              // طبقة محطات المترو كدوائر ملونة
              MarkerLayer(
                markers: [
                  ...MetroData.stations.map((station) {
                    final color = _getStationColor(station);
                    return Marker(
                      point: lat_lng.LatLng(station.latitude, station.longitude),
                      width: 22,
                      height: 22,
                      child: GestureDetector(
                        onTap: () {
                          final stLatLng = lat_lng.LatLng(station.latitude, station.longitude);
                          _onPointSelected(stLatLng, placeName: 'محطة ${station.nameAr}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 3.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // ماركر الموقع المحدد من المستخدم (يظهر فقط إذا تم الضغط أو البحث)
                  if (_selectedLatLng != null)
                    Marker(
                      point: _selectedLatLng!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. شريط البحث العلوي التفاعلي
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D34),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'مثال: عباس العقاد، المتحف المصري...',
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _searchPlace,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: () => _searchPlace(_searchController.text),
                  ),
                ],
              ),
            ),
          ),

          // 3. كارت العرض السفلي - يظهر فقط بعد اختيار المستخدم لمكان أو محطة على الخريطة
          if (_selectedLatLng != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D34),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _selectedPlace?.name ?? 'الموقع المحدد',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 8),
                          const Text('أقرب محطة مترو متاحة', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  _nearestStationResult?.station.nameAr ?? 'جاري الحساب...',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.directions_subway, color: Colors.blue, size: 22),
                            ],
                          ),
                          if (_nearestStationResult != null)
                            Text(
                              'المسافة تقريباً ${_nearestStationResult!.distanceLabelAr}',
                              style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 13),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () => _applySelection(asStart: false),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('استخدم كوجهة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () => _applySelection(asStart: true),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('استخدم كبداية', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }
}