import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool?> showPermissionDeniedDialog() {
  return Get.dialog<bool>(
    Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xFF2A2D34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.amberAccent),
            SizedBox(width: 8),
            Text('مطلوب إذن الموقع', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'نحتاج إلى إذن تحديد الموقع الإلكتروني لنتمكن من البحث واختيار أقرب محطة مترو إليك تلقائياً.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('حاول مرة أخرى', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

Future<void> showPermissionPermanentlyDeniedDialog({
  required Future<bool> Function() onOpenSettings,
}) {
  return Get.dialog(
    Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xFF2A2D34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings_suggest, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('مطلوب إذن الموقع', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'تم رفض إذن الوصول للموقع بشكل دائم. يرجى السماح بالوصول من إعدادات التطبيق في جهازك لمتابعة استخدام الخدمة.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await onOpenSettings();
              Get.back();
            },
            child: const Text('فتح الإعدادات', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

Future<void> showLocationServicesDisabledDialog({
  required Future<bool> Function() onOpenSettings,
}) {
  return Get.dialog(
    Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xFF2A2D34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.gps_off, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('خدمات الموقع متوقفة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'خدمات الـ GPS متوقفة على جهازك. يرجى تشغيل الموقع للمتابعة.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await onOpenSettings();
              Get.back();
            },
            child: const Text('فتح إعدادات الموقع', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}