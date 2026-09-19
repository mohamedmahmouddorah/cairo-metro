import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../errors/app_failure.dart';

abstract final class AppSnackbar {
  const AppSnackbar._();

  static void showError(AppFailure failure) {
    Get.snackbar(
      'تنبيه',
      failure.userMessageAr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2C1C1C),
      colorText: const Color(0xFFFFEBEE),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F).withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFEF5350),
          size: 24,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 12,
      borderWidth: 1.2,
      borderColor: const Color(0xFFE53935).withValues(alpha: 0.5),
      duration: const Duration(seconds: 5),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      mainButton: failure.requiresAction
          ? TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF8A80),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.settings, size: 18, color: Color(0xFFFF8A80)),
              label: const Text(
                'الإعدادات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () async {
                if (Get.isSnackbarOpen) Get.back();
                if (failure.actionType == SettingsActionType.locationSettings) {
                  await Geolocator.openLocationSettings();
                } else if (failure.actionType == SettingsActionType.appSettings) {
                  await openAppSettings();
                }
              },
            )
          : null,
    );
  }
}