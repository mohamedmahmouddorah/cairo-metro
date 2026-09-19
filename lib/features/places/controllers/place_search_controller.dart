import 'dart:async';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/services/history_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/nearest_station_service.dart';
import '../../../core/services/places_service.dart';
import '../../../data/models/nearest_station_result.dart';
import '../../../data/models/place_result.dart';

class PlaceSearchController extends GetxController {
  PlaceSearchController({
    required PlacesService placesService,
    required NearestStationService nearestStationService,
    required HistoryService historyService,
    required LocationService locationService,
  })  : _placesService = placesService,
        _nearestStationService = nearestStationService,
        _historyService = historyService,
        _locationService = locationService;

  final PlacesService _placesService;
  final NearestStationService _nearestStationService;
  final HistoryService _historyService;
  final LocationService _locationService;

  final query = ''.obs;
  final suggestions = <PlaceSuggestion>[].obs;
  final placeHistory = <PlaceResult>[].obs;
  final isSearching = false.obs;
  final isResolving = false.obs;
  final errorMessage = Rxn<String>();
  final outOfCoverageWarning = Rxn<String>(); // رسالة تحذير عند تجاوز الـ 20 كم
  final selectedPlace = Rxn<PlaceResult>();
  final nearest = Rxn<NearestStationResult>();

  Timer? _debounce;
  String _lastQuery = '';

  bool get usesGooglePlaces => _placesService.usesGooglePlaces;

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _loadHistory() async {
    placeHistory.assignAll(await _historyService.getPlaceHistory());
  }

  void onQueryChanged(String value) {
    query.value = value;
    selectedPlace.value = null;
    nearest.value = null;
    errorMessage.value = null;
    outOfCoverageWarning.value = null;

    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.placeSearchDebounceMs),
      () {
        unawaited(_runSearch(value));
      },
    );
  }

  Future<void> _runSearch(String value) async {
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      suggestions.clear();
      isSearching.value = false;
      return;
    }
    if (trimmed == _lastQuery && suggestions.isNotEmpty) return;
    if (!_placesService.usesGooglePlaces) return;

    isSearching.value = true;
    errorMessage.value = null;
    try {
      final results = await _placesService.searchSuggestions(trimmed);
      _lastQuery = trimmed;
      suggestions.assignAll(results);
      if (results.isEmpty) {
        errorMessage.value = AppFailure.noPlaceResults.userMessageAr;
      }
    } on AppFailure catch (failure) {
      suggestions.clear();
      errorMessage.value = failure.userMessageAr;
    } finally {
      isSearching.value = false;
    }
  }

  /// دالة جلب الموقع الحالي بضغطة زر داخل شاشة البحث أو الخريطة بدون إشعارات حمراء
  Future<void> useCurrentLocation() async {
    if (isResolving.value) return;
    isResolving.value = true;
    errorMessage.value = null;
    outOfCoverageWarning.value = null;

    try {
      final locFix = await _locationService.getCurrentPosition();
      final currentPlace = PlaceResult(
        name: 'موقعي الحالي',
        latitude: locFix.latitude,
        longitude: locFix.longitude,
      );
      await _applyPlace(currentPlace);
    } on AppFailure catch (failure) {
      // توجيه تلقائي للإعدادات بدون إظهار أخطاء مسدودة
      if (failure.kind == AppFailureKind.locationDisabled) {
        await _locationService.openLocationSettings();
      } else if (failure.kind == AppFailureKind.permissionDenied ||
                 failure.kind == AppFailureKind.permissionPermanentlyDenied) {
        await _locationService.openAppSettings();
      } else {
        errorMessage.value = failure.userMessageAr;
      }
    } finally {
      isResolving.value = false;
    }
  }

  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    if (isResolving.value) return;
    isResolving.value = true;
    errorMessage.value = null;
    outOfCoverageWarning.value = null;

    try {
      final place = await _placesService.details(
        suggestion.placeId,
        fallbackName: suggestion.primaryText,
      );
      await _applyPlace(place);
    } on AppFailure catch (failure) {
      errorMessage.value = failure.userMessageAr;
    } finally {
      isResolving.value = false;
    }
  }

  Future<void> submitTypedQuery() async {
    final trimmed = query.value.trim();
    if (trimmed.isEmpty || isResolving.value) return;

    isResolving.value = true;
    errorMessage.value = null;
    outOfCoverageWarning.value = null;

    try {
      if (_placesService.usesGooglePlaces && suggestions.isNotEmpty) {
        await selectSuggestion(suggestions.first);
        return;
      }

      final results = await _placesService.geocodeQuery(trimmed);
      if (results.isEmpty) {
        errorMessage.value = AppFailure.noPlaceResults.userMessageAr;
        return;
      }

      await _applyPlace(results.first);
    } on AppFailure catch (failure) {
      errorMessage.value = failure.userMessageAr;
    } finally {
      isResolving.value = false;
    }
  }

  Future<void> selectHistory(PlaceResult place) async {
    await _applyPlace(place);
  }

  Future<void> clearHistory() async {
    await _historyService.clearPlaceHistory();
    placeHistory.clear();
  }

  Future<void> _applyPlace(PlaceResult place) async {
    selectedPlace.value = place;
    
    final nearestResult = await _nearestStationService.findNearest(
      latitude: place.latitude,
      longitude: place.longitude,
    );

    nearest.value = nearestResult;

    // فحص شرط تجاوز الـ 20 كيلومتر (20,000 متر) مباشرة من المسافة الحسابية
    if (nearestResult.distanceMeters > 20000.0) {
      final distanceKm = (nearestResult.distanceMeters / 1000).toStringAsFixed(1);
      outOfCoverageWarning.value =
          'الموقع خارج نطاق المترو المباشر. أقرب محطة هي ${nearestResult.station.nameAr} وتبعد $distanceKm كم.';
    } else {
      outOfCoverageWarning.value = null;
    }

    await _historyService.savePlaceSearch(place);
    await _loadHistory();
  }

  Future<void> openPlaceOnMap() async {
    final place = selectedPlace.value;
    if (place == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}