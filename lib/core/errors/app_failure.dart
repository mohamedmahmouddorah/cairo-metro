import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum AppFailureKind {
  network,
  timeout,
  api,
  invalidResponse,
  permissionDenied,
  permissionPermanentlyDenied,
  locationDisabled,
  locationUnavailable,
  noResults,
  noNearbyStation,
  noRoute,
  invalidStation,
  sameStation,
  missingStart,
  missingDestination,
  unknown,
}

enum SettingsActionType {
  none,
  locationSettings, 
  appSettings,      
}

@immutable
class AppFailure implements Exception {
  final AppFailureKind kind;
  final String userMessageAr;
  final String? debugMessage;
  final SettingsActionType actionType;

  const AppFailure({
    required this.kind,
    required this.userMessageAr,
    this.debugMessage,
    this.actionType = SettingsActionType.none,
  });

  bool get requiresAction => actionType != SettingsActionType.none;

  @override
  String toString() => debugMessage ?? userMessageAr;

  static const missingStart = AppFailure(
    kind: AppFailureKind.missingStart,
    userMessageAr: 'يرجى اختيار محطة البداية أولاً.',
  );

  static const missingDestination = AppFailure(
    kind: AppFailureKind.missingDestination,
    userMessageAr: 'يرجى اختيار محطة الوصول أولاً.',
  );

  static const sameStation = AppFailure(
    kind: AppFailureKind.sameStation,
    userMessageAr: 'محطة البداية لا يمكن أن تكون نفس محطة الوصول.',
  );

  static const noRoute = AppFailure(
    kind: AppFailureKind.noRoute,
    userMessageAr: 'تعذر العثور على مسار بين هاتين المحطتين.',
  );

  static const network = AppFailure(
    kind: AppFailureKind.network,
    userMessageAr: 'لا يوجد اتصال بالإنترنت.\nيرجى تشغيل الشبكة لإكمال البحث عن المكان.',
  );

  static const timeout = AppFailure(
    kind: AppFailureKind.timeout,
    userMessageAr: 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.',
  );

  static const noPlaceResults = AppFailure(
    kind: AppFailureKind.noResults,
    userMessageAr: 'لم يتم العثور على نتائج لهذا المكان.',
  );

  static const locationDisabled = AppFailure(
    kind: AppFailureKind.locationDisabled,
    userMessageAr: 'خدمة الموقع مغلقة. اضغط لفتح الإعدادات.',
    actionType: SettingsActionType.locationSettings,
  );

  static const permissionDenied = AppFailure(
    kind: AppFailureKind.permissionDenied,
    userMessageAr: 'يحتاج التطبيق لإذن الموقع لتحديد أقرب محطة مترو.',
  );

  static const permissionPermanentlyDenied = AppFailure(
    kind: AppFailureKind.permissionPermanentlyDenied,
    userMessageAr: 'تم رفض إذن الموقع بصفة دائمة. يرجى تفعيله من إعدادات التطبيق.',
    actionType: SettingsActionType.appSettings,
  );

  static const locationUnavailable = AppFailure(
    kind: AppFailureKind.locationUnavailable,
    userMessageAr: 'تعذر تحديد موقعك الحالي. تأكد من وجود إشارة GPS جيدة.',
  );

  static const noNearbyStation = AppFailure(
    kind: AppFailureKind.noNearbyStation,
    userMessageAr: 'تعذر تحديد أقرب محطة مترو لموقعك الحالي.',
  );

  factory AppFailure.fromException(Object error) {
    if (error is AppFailure) return error;
    if (error is SocketException) return AppFailure.network;
    if (error is TimeoutException) return AppFailure.timeout;

    return AppFailure(
      kind: AppFailureKind.unknown,
      userMessageAr: 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.',
      debugMessage: error.toString(),
    );
  }
}