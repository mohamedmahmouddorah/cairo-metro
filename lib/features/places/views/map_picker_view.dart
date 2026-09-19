import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import '../../../core/errors/app_failure.dart';
import '../../../core/services/history_service.dart';
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
  final HistoryService _historyService = Get.find<HistoryService>();
  final HomeController _homeController = Get.find<HomeController>();

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  final lat_lng.LatLng _defaultCenter = const lat_lng.LatLng(30.0444, 31.2357);

  lat_lng.LatLng? _selectedLatLng;
  NearestStationResult? _nearestStationResult;
  PlaceResult? _selectedPlace;
  bool _isLoading = false;

  void _showAppSnackbar(String title, String message, {bool isError = true}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFF2A2D34),
      colorText: Colors.white,
      titleText: Text(
        title,
        style: TextStyle(
          color: isError ? Colors.redAccent : Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? Colors.redAccent : Colors.blueAccent,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  Color _getStationColor(MetroStation station) {
    if (station.lineIds.contains(1)) {
      return const Color(0xFF2563EB);
    } else if (station.lineIds.contains(2)) {
      return const Color(0xFFEF4444);
    } else if (station.lineIds.contains(3)) {
      return const Color(0xFF10B981);
    }
    return Colors.grey;
  }

  Future<void> _onPointSelected(lat_lng.LatLng latLng, {String? placeName, String? formattedAddress, bool isFromSearch = false}) async {
    setState(() {
      _selectedLatLng = latLng;
      _isLoading = true;
    });

    try {
      final nearest = await _nearestStationService.findNearest(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );

      final String resolvedName = placeName ?? 'نقطة على الخريطة';
      final String resolvedAddress = formattedAddress ?? (placeName != null ? 'منطقة $placeName' : 'إحداثيات (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})');

      final place = PlaceResult(
        name: resolvedName,
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        formattedAddress: resolvedAddress,
      );

      setState(() {
        _nearestStationResult = nearest;
        _selectedPlace = place;
      });

      // حفظ في السجل فقط إذا كان بحثاً ناجحاً وصحيحاً من شريط البحث
      if (isFromSearch && nearest.station.nameAr.isNotEmpty) {
        await _historyService.savePlaceSearch(place);
      }
    } on SocketException {
      _showAppSnackbar('خطأ في الاتصال', 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.');
    } catch (_) {
      _showAppSnackbar('تنبيه', 'تعذر حساب أقرب محطة لهذا الموقع.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchPlace(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _selectedLatLng = null;
      _selectedPlace = null;
      _nearestStationResult = null;
    });

    try {
      final results = await _placesService.geocodeQuery(trimmed);
      
      if (results.isNotEmpty) {
        final place = results.first;
        
        // التحقق لمنع الكلمات العشوائية الوهمية على الهاتف
        if (!trimmed.contains(' ') && trimmed.length > 5) {
          final cleanQuery = trimmed.toLowerCase();
          final cleanName = place.name.toLowerCase();
          final cleanAddress = (place.formattedAddress ?? '').toLowerCase();
          if (!cleanName.contains(cleanQuery) && !cleanAddress.contains(cleanQuery)) {
            _showAppSnackbar('عذراً', 'لا يوجد مكان بهذا الاسم. تأكد من كتابة اسم صحيح.');
            setState(() => _isLoading = false);
            return;
          }
        }

        final newLatLng = lat_lng.LatLng(place.latitude, place.longitude);

        _mapController.move(newLatLng, 15.0);
        await _onPointSelected(
          newLatLng, 
          placeName: place.name, 
          formattedAddress: place.formattedAddress, 
          isFromSearch: true,
        );
      } else {
        _showAppSnackbar('عذراً', 'لا يوجد مكان بهذا الاسم. تأكد من كتابة اسم صحيح.');
      }
    } on AppFailure catch (failure) {
      _showAppSnackbar('خطأ', failure.userMessageAr);
    } on SocketException {
      _showAppSnackbar('خطأ في الاتصال', 'لا يوجد اتصال بالإنترنت للمتابعة.');
    } catch (_) {
      _showAppSnackbar('تنبيه', 'حدث خطأ أثناء البحث. تأكد من صحة الكلمة المدخلة.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showSearchHistoryBottomSheet() async {
    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setStateModal) {
          return FutureBuilder<List<PlaceResult>>(
            future: _historyService.getPlaceHistory(),
            builder: (context, snapshot) {
              final history = snapshot.data ?? [];

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (history.isNotEmpty)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              await _historyService.clearPlaceHistory();
                              setStateModal(() {});
                              _showAppSnackbar('السجل', 'تم مسح الكل بنجاح.', isError: false);
                            },
                            child: const Text(
                              'مسح الكل',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        const Text(
                          'سجل البحث',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, thickness: 1),
                    if (history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'لا توجد عمليات بحث محفوظة محلياً بعد',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: history.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 16),
                          itemBuilder: (context, index) {
                            final place = history[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Get.back();
                                final latLng = lat_lng.LatLng(place.latitude, place.longitude);
                                _mapController.move(latLng, 15.0);
                                _onPointSelected(
                                  latLng, 
                                  placeName: place.name, 
                                  formattedAddress: place.formattedAddress,
                                  isFromSearch: false,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                      tooltip: 'حذف العنصر',
                                      onPressed: () async {
                                        await _historyService.deletePlaceHistoryItem(place);
                                        setStateModal(() {});
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            place.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.right,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            place.formattedAddress ?? place.name,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.right,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13.0,
              onTap: (tapPosition, point) => _onPointSelected(point, isFromSearch: false),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cairometro.app',
              ),
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
                          _onPointSelected(stLatLng, placeName: 'محطة ${station.nameAr}', isFromSearch: false);
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
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D34),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white70),
                    tooltip: 'سجل البحث',
                    onPressed: _showSearchHistoryBottomSheet,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن مكان (مثل: نادي السكة)...',
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
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
                          // عرض العنوان التفصيلي الكامل والواضح للمكان بخط بارز
                          Text(
                            _selectedPlace?.formattedAddress ?? _selectedPlace?.name ?? 'الموقع المحدد',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          const Text('أقرب محطة مترو', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  // التحقق البرمجي: إذا كانت المسافة أكبر من 20 كم، يظهر "خارج نطاق شبكة المترو"
                                  (_nearestStationResult != null && _nearestStationResult!.distanceMeters > 20000)
                                      ? 'خارج نطاق شبكة المترو'
                                      : (_nearestStationResult?.station.nameAr ?? 'جاري الحساب...'),
                                  style: TextStyle(
                                    color: (_nearestStationResult != null && _nearestStationResult!.distanceMeters > 20000)
                                        ? Colors.orangeAccent
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                (_nearestStationResult != null && _nearestStationResult!.distanceMeters > 20000)
                                    ? Icons.warning_amber_rounded
                                    : Icons.directions_subway,
                                color: (_nearestStationResult != null && _nearestStationResult!.distanceMeters > 20000)
                                    ? Colors.orangeAccent
                                    : Colors.blue,
                                size: 20,
                              ),
                            ],
                          ),
                          if (_nearestStationResult != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                (_nearestStationResult!.distanceMeters > 20000)
                                    ? 'هذا الموقع بعيد جداً عن خطوط المترو'
                                    : 'المسافة تقريباً ${_nearestStationResult!.distanceLabelAr}',
                                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
                              ),
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