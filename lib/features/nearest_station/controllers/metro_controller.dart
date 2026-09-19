import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/nearest_station_service.dart';
import '../../../data/models/metro_station.dart';
import '../../home/views/widgets/location_permission_dialogs.dart';

class MetroController extends GetxController {
  MetroController({
    LocationService? locationService,
    NearestStationService? nearestStationService,
  })  : _locationService = locationService ?? Get.find<LocationService>(),
        _nearestStationService = nearestStationService ?? Get.find<NearestStationService>();

  final LocationService _locationService;
  final NearestStationService _nearestStationService;

  final isLoading = false.obs;
  final nearestStation = Rxn<MetroStation>();
  final distanceKm = 0.0.obs;
  final distanceLabel = ''.obs;
  final isOutOfCoverage = false.obs; // حالة التغطية الجغرافية (أكثر من 20 كم)

  Future<void> findNearestMetroStation() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      isOutOfCoverage.value = false;

      final fix = await _locationService.getCurrentPosition();
      final result = await _nearestStationService.findNearest(
        latitude: fix.latitude,
        longitude: fix.longitude,
      );

      nearestStation.value = result.station;
      distanceKm.value = result.distanceMeters / 1000;
      distanceLabel.value = result.distanceLabelAr;

      // فحص شرط تجاوز نطاق الـ 20 كيلومتر (20,000 متر)
      if (result.distanceMeters > 20000.0) {
        isOutOfCoverage.value = true;
        Get.snackbar(
          'تنبيه النطاق الجغرافي',
          'موقعك الحالي خارج نطاق خدمة المترو المباشر. أقرب محطة متاحة هي ${result.station.nameAr} وتبعد ${distanceKm.value.toStringAsFixed(1)} كم.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.amber.shade900.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } on AppFailure catch (failure) {
      await _handleFailure(failure);
    } catch (e) {
      Get.snackbar('خطأ', AppFailure.locationUnavailable.userMessageAr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleFailure(AppFailure failure) async {
    switch (failure.kind) {
      case AppFailureKind.permissionDenied:
        final retry = await showPermissionDeniedDialog();
        if (retry == true) await findNearestMetroStation();
        break;
      case AppFailureKind.permissionPermanentlyDenied:
        await showPermissionPermanentlyDeniedDialog(onOpenSettings: _locationService.openAppSettings);
        break;
      case AppFailureKind.locationDisabled:
        await showLocationServicesDisabledDialog(onOpenSettings: _locationService.openLocationSettings);
        break;
      default:
        Get.snackbar('تنبيه', failure.userMessageAr);
        break;
    }
  }

  Future<void> openGoogleMapsNavigation(double destinationLat, double destinationLng) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=walking',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('خطأ', 'تعذر فتح تطبيق الخرائط');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر فتح تطبيق الخرائط');
    }
  }
}