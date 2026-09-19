import 'package:flutter/foundation.dart';

@immutable
abstract final class AppConstants {
  const AppConstants._();

  static const String appName = 'Cairo Metro';
  
  // Cairo Central Coordinates (ميدان التحرير / السادات)
  static const double cairoLat = 30.0444;
  static const double cairoLng = 31.2357;
  
  // Performance & UX Limits
  static const int placeSearchDebounceMs = 400;
  static const int locationTimeoutSeconds = 12;
  static const int maxPlaceHistory = 8;
  static const int minutesPerStation = 2; // دقيقتين بين كل محطة ومحطة
}

@immutable
abstract final class FareCalculator {
  const FareCalculator._();

  /// حساب سعر التذكرة بناءً على الشرايح الجديدة
  static int calculateFare(int stationCount) {
    if (stationCount <= 0) return 0;
    if (stationCount <= 9) return 10;
    if (stationCount <= 16) return 12;
    if (stationCount <= 23) return 15;
    return 20; // أكثر من 23 محطة
  }

  /// حساب الوقت التقديري بالدقائق (عدد المحطات × 2 دقيقة)
  static int calculateEstimatedMinutes(int stationCount) {
    if (stationCount <= 0) return 0;
    return stationCount * AppConstants.minutesPerStation;
  }
}