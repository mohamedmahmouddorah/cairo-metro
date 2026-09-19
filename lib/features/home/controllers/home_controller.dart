import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/services/graph_service.dart';
import '../../../core/services/history_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/nearest_station_service.dart';
import '../../../core/services/places_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/metro_data.dart';
import '../../../data/models/metro_station.dart';
import '../../../data/models/nearest_station_result.dart';
import '../../../data/models/place_result.dart';
import '../views/result_view.dart';

class HomeController extends GetxController {
  final GraphService _graphService = Get.find<GraphService>();
  final HistoryService historyService = Get.find<HistoryService>();
  final NearestStationService nearestStationService = Get.find<NearestStationService>();
  final PlacesService placesService = Get.find<PlacesService>();
  final LocationService _locationService = Get.find<LocationService>();

  // Selected Stations
  final startStation = Rxn<MetroStation>();
  final endStation = Rxn<MetroStation>();

  // Place labels
  final startPlaceLabel = RxnString();
  final endPlaceLabel = RxnString();

  // Nearest station info card
  final nearestStationInfo = Rxn<NearestStationResult>();

  // فلتر اختيار المحطات (0: الكل, 1: الخط الأول, 2: الخط الثاني, 3: الخط الثالث)
  final selectedLineFilter = 0.obs;

  // Preferences & Loading States
  final leastTransfers = false.obs;
  final isLocatingStart = false.obs;

  // History State
  final historyList = <SearchHistory>[].obs;

  // Workers for Memory & Storage Performance
  Worker? _startStationWorker;
  Worker? _endStationWorker;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    _restoreLastSelectedStations();

    // استخدام Debounce للحد من الكتابة السريعة والمتكررة للـ Storage
    _startStationWorker = debounce(startStation, (_) => _saveCurrentStations(), time: const Duration(milliseconds: 500));
    _endStationWorker = debounce(endStation, (_) => _saveCurrentStations(), time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    // حماية الميموري من الـ Memory Leaks وإلغاء استهلاك الموارد
    _startStationWorker?.dispose();
    _endStationWorker?.dispose();
    super.onClose();
  }

  /// جلب المحطات المفلترة حسب الخط المحدد في أزرار الفلترة (Chips)
  List<MetroStation> get filteredStations {
    if (selectedLineFilter.value == 0) {
      return MetroData.stations;
    }
    return MetroData.stations
        .where((station) => station.lineIds.contains(selectedLineFilter.value))
        .toList();
  }

  Future<void> loadHistory() async {
    final history = await historyService.getHistory();
    historyList.assignAll(history);
  }

  Future<void> _restoreLastSelectedStations() async {
    final startId = await historyService.getLastStartStationId();
    final endId = await historyService.getLastEndStationId();

    if (startId != null) {
      startStation.value = MetroData.stationById(startId);
    }
    if (endId != null) {
      endStation.value = MetroData.stationById(endId);
    }
  }

  void _saveCurrentStations() {
    historyService.saveLastSelectedStations(
      startStation.value?.id,
      endStation.value?.id,
    );
  }

  Future<void> deleteSingleHistory(SearchHistory item) async {
    historyList.remove(item);
    await historyService.deleteHistoryItem(item);
  }

  Future<void> clearHistory() async {
    await historyService.clearHistory();
    historyList.clear();
  }

  /// تحديد أقرب محطة لموقع المستخدم الحالي بدون إشعارات حمراء مع التوجيه المباشر للإعدادات
  Future<void> findNearestStartStation() async {
    try {
      isLocatingStart.value = true;

      // جلب الموقع باستخدام LocationService المحدثة
      final locationFix = await _locationService.getCurrentPosition();

      final result = await nearestStationService.findNearest(
        latitude: locationFix.latitude,
        longitude: locationFix.longitude,
      );

      // تعيين أقرب محطة تلقائياً كبداية
      startStation.value = result.station;
      nearestStationInfo.value = result;
      startPlaceLabel.value = 'موقعك الحالي';

      // التحقق من شرط الـ 20 كيلومتر (20,000 متر)
      if (result.distanceMeters > 20000.0) {
        final distanceKm = (result.distanceMeters / 1000).toStringAsFixed(1);
        Get.snackbar(
          'تنبيه النطاق الجغرافي',
          'موقعك الحالي خارج نطاق خطوط المترو المباشر. أقرب محطة هي ${result.station.nameAr} وتبعد $distanceKm كم.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.amber.shade900.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'تم تعيين محطة البداية',
          'أقرب محطة بداية: ${result.station.nameAr}\n${result.distanceLabelAr}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withValues(alpha: 0.85),
          colorText: Colors.white,
        );
      }
    } on AppFailure catch (failure) {
      // التوجه المباشر للإعدادات ودون إظهار أي إشعار أحمر (AppSnackbar)
      if (failure.kind == AppFailureKind.locationDisabled) {
        await _locationService.openLocationSettings();
      } else if (failure.kind == AppFailureKind.permissionDenied ||
                 failure.kind == AppFailureKind.permissionPermanentlyDenied) {
        await _locationService.openAppSettings();
      }
    } catch (_) {
      // استجابة صامتة عند الأخطاء المجهولة وتجنب إزعاج المستخدم بالإشعارات
    } finally {
      isLocatingStart.value = false;
    }
  }

  void applyPlaceAsStation(PlaceResult place, NearestStationResult nearest, {required bool asStart}) {
    if (asStart) {
      startStation.value = nearest.station;
      startPlaceLabel.value = place.name;
      nearestStationInfo.value = nearest;
    } else {
      endStation.value = nearest.station;
      endPlaceLabel.value = place.name;
    }
  }

  void calculateRoute() {
    if (startStation.value == null || endStation.value == null) {
      AppSnackbar.showError(
        startStation.value == null ? AppFailure.missingStart : AppFailure.missingDestination,
      );
      return;
    }

    if (startStation.value!.id == endStation.value!.id) {
      AppSnackbar.showError(AppFailure.sameStation);
      return;
    }

    historyService.saveSearch(startStation.value!, endStation.value!);
    loadHistory();

    final result = _graphService.calculateRoute(
      startStation.value!.id,
      endStation.value!.id,
      leastTransfers: leastTransfers.value,
    );

    if (result != null) {
      Get.to(() => ResultView(result: result, start: startStation.value!, end: endStation.value!));
    } else {
      AppSnackbar.showError(AppFailure.noRoute);
    }
  }
}