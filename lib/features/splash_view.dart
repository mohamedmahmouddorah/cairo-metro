import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/graph_service.dart';
import '../core/services/history_service.dart';
import '../core/services/location_service.dart';
import '../core/services/nearest_station_service.dart';
import '../core/services/places_service.dart';
import '../core/services/recent_trip_service.dart';
import '../features/home/controllers/home_controller.dart';
import 'home/views/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _registerServices() {
    if (!Get.isRegistered<PlacesService>()) {
      final placesService = PlacesService();
      Get.put(placesService, permanent: true);
      Get.put(GraphService(), permanent: true);
      Get.put(HistoryService(), permanent: true);
      Get.put(LocationService(), permanent: true);
      Get.put(NearestStationService(placesService: placesService), permanent: true);
      Get.put(RecentTripService(), permanent: true);
      Get.put(HomeController(), permanent: true);
    }
  }

  void _navigateToHome() async {
    // 1. تسجيل الخدمات أثناء عرض شاشة التحميل
    _registerServices();

    // 2. الانتظار لمدة ثانيتين لإنهاء العرض
    await Future.delayed(const Duration(seconds: 2));

    // 3. الانتقال لصفحة الهوم
    Get.off(() => const HomeView(), transition: Transition.fadeIn);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A2540).withValues(alpha: 0.85),
                      Colors.transparent,
                      const Color(0xFF0A2540).withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.train_rounded,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'Metro ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'App',
                            style: TextStyle(color: Color(0xFF42A5F5)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your Metro Journey,\nMade Easy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}