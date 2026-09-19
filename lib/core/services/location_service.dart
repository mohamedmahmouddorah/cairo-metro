import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../errors/app_failure.dart';

class LocationFix {
  final double latitude;
  final double longitude;

  const LocationFix({required this.latitude, required this.longitude});
}

class LocationService {
  /// جلب موقع الجهاز الحالي بأعلى كفاءة وسرعة استجابة بدون رسائل تنبيهية
  Future<LocationFix> getCurrentPosition() async {
    // 1. التحقق من تفعيل خدمة الـ GPS على الجهاز
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await openLocationSettings(); // فتح إعدادات الموقع فوراً
      throw AppFailure.locationDisabled;
    }

    // 2. التحقق من الصلاحيات والتوجه المباشر للإعدادات عند الرفض
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await openAppSettings(); // فتح إعدادات التطبيق فوراً عند الرفض
        throw AppFailure.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings(); // فتح إعدادات التطبيق فوراً
      throw AppFailure.permissionPermanentlyDenied;
    }

    try {
      // 3. التسريع: محاولة جلب آخر موقع محفوط على الجهاز فوراً (0 ثوانٍ تأخير)
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && _isPlausible(lastPosition.latitude, lastPosition.longitude)) {
        return LocationFix(
          latitude: lastPosition.latitude,
          longitude: lastPosition.longitude,
        );
      }

      // 4. إذا لم يتوفر أحدث موقع، نطلب الموقع الفعلي بدقة متوسطة ومهلة 3 ثوانٍ فقط لتفادي التعليق
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium, // أسرع بكثير من high وتكفي جداً لحساب محطات المترو
          timeLimit: Duration(seconds: 3),   // استجابة سريعة جداً
        ),
      );

      if (!_isPlausible(position.latitude, position.longitude)) {
        throw AppFailure.locationUnavailable;
      }

      return LocationFix(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      // في حالة انقضاء الوقت، محاولة جلب موقع بدقة منخفضة سريعة كخيار أخير
      try {
        final lowPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 2),
          ),
        );
        return LocationFix(latitude: lowPos.latitude, longitude: lowPos.longitude);
      } catch (_) {
        throw AppFailure.timeout;
      }
    } catch (e) {
      throw AppFailure(
        kind: AppFailureKind.locationUnavailable,
        userMessageAr: AppFailure.locationUnavailable.userMessageAr,
        debugMessage: e.toString(),
      );
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  bool _isPlausible(double lat, double lng) {
    return lat.abs() <= 90 && lng.abs() <= 180 && !(lat == 0 && lng == 0);
  }
}