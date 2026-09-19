import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/metro_controller.dart';

class MetroView extends StatefulWidget {
  const MetroView({super.key});

  @override
  State<MetroView> createState() => _MetroViewState();
}

class _MetroViewState extends State<MetroView> {
  late final MetroController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MetroController());
  }

  @override
  void dispose() {
    Get.delete<MetroController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('أقرب محطة مترو', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('جاري حساب المسافة بدقة...', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }

                final station = controller.nearestStation.value;

                if (station == null) {
                  return const Text(
                    'اضغط على الزر أدناه لتحديد أقرب محطة مترو لموقعك الحالي',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  );
                }

                return Card(
                  color: const Color(0xFF2A2D34),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // عرض كارت التنبيه إذا كان الموقع خارج نطاق الـ 20 كم
                        if (controller.isOutOfCoverage.value) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade900.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amberAccent.shade400),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'موقعك الحالي خارج نطاق تغطية شبكة المترو المباشرة (أكثر من 20 كم).',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        const Icon(Icons.directions_subway, size: 48, color: Colors.blue),
                        const SizedBox(height: 12),
                        Text(
                          'أقرب محطة: ${station.nameAr}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text('الخطوط: ${station.lineIds.join(', ')}', style: const TextStyle(color: Colors.white54)),
                        const SizedBox(height: 8),
                        Text(
                          controller.distanceLabel.value.isEmpty
                              ? 'تبعد عنك: ${controller.distanceKm.value.toStringAsFixed(2)} كم'
                              : controller.distanceLabel.value,
                          style: const TextStyle(fontSize: 16, color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.openGoogleMapsNavigation(station.latitude, station.longitude);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.directions),
                          label: const Text('الذهاب إلى المحطة عبر Google Maps'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => controller.findNearestMetroStation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.my_location),
                label: const Text('تحديد أقرب محطة مترو لموقعي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}