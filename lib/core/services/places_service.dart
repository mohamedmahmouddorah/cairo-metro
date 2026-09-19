import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../data/models/place_result.dart';
import '../config/app_config.dart';
import '../app_constants.dart';
import '../errors/app_failure.dart';

class PlaceSuggestion {
  final String placeId;
  final String primaryText;
  final String? secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.primaryText,
    this.secondaryText,
  });
}

class PlacesService {
  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  int _searchGeneration = 0;

  bool get usesGooglePlaces => AppConfig.hasGooglePlaces;

  /// تطهير النص العربي وتوحيد الأحرف لتقليل أخطاء البحث
  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '')
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }

  /// توليد الصيغ المختلفة للكلمة بكفاءة عالية في الذاكرة
  List<String> _generateQueryVariants(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final normalized = _normalizeArabic(trimmed);
    final Set<String> variants = {trimmed, normalized};

    if (trimmed.endsWith('ه')) {
      variants.add('${trimmed.substring(0, trimmed.length - 1)}ة');
    } else if (trimmed.endsWith('ة')) {
      variants.add('${trimmed.substring(0, trimmed.length - 1)}ه');
    }

    return variants.toList(growable: false);
  }

  /// اقتراحات أوتوكومبليت عبر Google Places API
  Future<List<PlaceSuggestion>> searchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final generation = ++_searchGeneration;

    if (!AppConfig.hasGooglePlaces) {
      return const [];
    }

    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': trimmed,
        'key': AppConfig.googleMapsApiKey,
        'components': 'country:eg',
        'location': '${AppConstants.cairoLat},${AppConstants.cairoLng}',
        'radius': '50000', // نطاق 50 كم يغطي القاهرة ومنافذ الدلتا
        'language': 'ar',
      });

      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (generation != _searchGeneration) return const [];

      if (response.statusCode != 200) {
        throw AppFailure(
          kind: AppFailureKind.api,
          userMessageAr: 'تعذر البحث عن المكان. حاول مرة أخرى.',
          debugMessage: 'Places autocomplete HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AppFailure(
          kind: AppFailureKind.invalidResponse,
          userMessageAr: 'تعذر قراءة نتيجة البحث.',
        );
      }

      final status = decoded['status'] as String? ?? '';
      if (status == 'ZERO_RESULTS') return const [];
      if (status == 'OVER_QUERY_LIMIT' || status == 'REQUEST_DENIED' || status == 'INVALID_REQUEST') {
        throw AppFailure(
          kind: AppFailureKind.api,
          userMessageAr: 'تعذر البحث عن المكان. حاول مرة أخرى.',
          debugMessage: 'Places autocomplete status $status ${decoded['error_message']}',
        );
      }
      if (status != 'OK') {
        throw AppFailure(
          kind: AppFailureKind.api,
          userMessageAr: 'تعذر البحث عن المكان. حاول مرة أخرى.',
          debugMessage: 'Places autocomplete status $status',
        );
      }

      final predictions = decoded['predictions'];
      if (predictions is! List) return const [];

      return predictions.whereType<Map<String, dynamic>>().map((item) {
        final structured = item['structured_formatting'] as Map<String, dynamic>?;
        return PlaceSuggestion(
          placeId: item['place_id'] as String? ?? '',
          primaryText: structured?['main_text'] as String? ?? item['description'] as String? ?? '',
          secondaryText: structured?['secondary_text'] as String?,
        );
      }).where((s) => s.placeId.isNotEmpty && s.primaryText.isNotEmpty).toList(growable: false);
    } on TimeoutException {
      throw AppFailure.timeout;
    } on SocketException {
      throw AppFailure.network;
    } on http.ClientException {
      throw AppFailure.network;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw AppFailure(
        kind: AppFailureKind.api,
        userMessageAr: 'تعذر البحث عن المكان. حاول مرة أخرى.',
        debugMessage: e.toString(),
      );
    }
  }

  /// جلب تفاصيل مكان محدد برقم PlaceId
  Future<PlaceResult> details(String placeId, {String? fallbackName}) async {
    if (!AppConfig.hasGooglePlaces) {
      throw const AppFailure(
        kind: AppFailureKind.api,
        userMessageAr: 'بحث الأماكن يتطلب مفتاح Google Maps API.',
      );
    }

    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
        'place_id': placeId,
        'fields': 'name,geometry,formatted_address',
        'key': AppConfig.googleMapsApiKey,
        'language': 'ar',
      });

      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw AppFailure(
          kind: AppFailureKind.api,
          userMessageAr: 'تعذر تحميل تفاصيل المكان.',
          debugMessage: 'Place details HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AppFailure(
          kind: AppFailureKind.invalidResponse,
          userMessageAr: 'تعذر قراءة تفاصيل المكان.',
        );
      }

      final status = decoded['status'] as String? ?? '';
      if (status != 'OK') {
        throw AppFailure(
          kind: AppFailureKind.api,
          userMessageAr: 'تعذر تحميل تفاصيل المكان.',
          debugMessage: 'Place details status $status',
        );
      }

      final result = decoded['result'] as Map<String, dynamic>?;
      final geometry = result?['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        throw const AppFailure(
          kind: AppFailureKind.invalidResponse,
          userMessageAr: 'تعذر قراءة إحداثيات المكان.',
        );
      }

      return PlaceResult(
        name: result?['name'] as String? ?? fallbackName ?? '',
        latitude: lat,
        longitude: lng,
        formattedAddress: result?['formatted_address'] as String?,
        placeId: placeId,
      );
    } on TimeoutException {
      throw AppFailure.timeout;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw AppFailure(
        kind: AppFailureKind.network,
        userMessageAr: AppFailure.network.userMessageAr,
        debugMessage: e.toString(),
      );
    }
  }

  /// بحث جغرافي ذكي محسّن يمنع التشتت والربط العشوائي بين المحافظات
  Future<List<PlaceResult>> geocodeQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final variants = _generateQueryVariants(trimmed);

    try {
      for (final variant in variants) {
        // 1. استخدام صيغة بحث مرنة تعتمد على الدولة "مصر" لعدم تقييد القادمين من الأقاليم بالقاهرة فقط
        final formattedSearch = "$variant, مصر";

        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?'
          'q=${Uri.encodeComponent(formattedSearch)}'
          '&format=json'
          '&addressdetails=1'
          '&limit=10'
          '&countrycodes=eg'
          // حصر مربع العرض ليشمل شبكة القليوبية والدلتا ومداخل القاهرة
          '&viewbox=30.0,31.8,32.0,29.5'
          '&bounded=0'
        );

        final response = await _client.get(
          uri,
          headers: {'User-Agent': 'CairoMetroApp/1.0 (contact@cairometro.app)'},
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final List decoded = jsonDecode(response.body);
          if (decoded.isNotEmpty) {
            final validResults = <PlaceResult>[];

            for (final item in decoded) {
              final lat = double.tryParse(item['lat'].toString()) ?? 0.0;
              final lon = double.tryParse(item['lon'].toString()) ?? 0.0;
              final displayName = item['display_name']?.toString() ?? trimmed;

              if (lat != 0.0 && lon != 0.0) {
                final nameParts = displayName.split(',');
                final mainName = nameParts.first.trim();

                validResults.add(
                  PlaceResult(
                    name: mainName.isNotEmpty ? mainName : trimmed,
                    latitude: lat,
                    longitude: lon,
                    formattedAddress: displayName,
                  ),
                );
              }
            }

            if (validResults.isNotEmpty) {
              // فرز النتائج حسب القرب من مركز الخدمة الحسابي للشبكة
              validResults.sort((a, b) {
                final distA = Geolocator.distanceBetween(
                    AppConstants.cairoLat, AppConstants.cairoLng, a.latitude, a.longitude);
                final distB = Geolocator.distanceBetween(
                    AppConstants.cairoLat, AppConstants.cairoLng, b.latitude, b.longitude);
                return distA.compareTo(distB);
              });

              return validResults;
            }
          }
        }
      }

      // 2. المحاولة الثانية كـ Fallback باستخدام الجيوكود الخاص بالمنصة
      for (final variant in variants) {
        try {
          final locations = await locationFromAddress('$variant, Egypt');
          if (locations.isNotEmpty) {
            return locations.take(5).map((location) {
              return PlaceResult(
                name: trimmed,
                latitude: location.latitude,
                longitude: location.longitude,
                formattedAddress: '$trimmed، مصر',
              );
            }).toList(growable: false);
          }
        } catch (_) {}
      }

      return const [];
    } on TimeoutException {
      throw AppFailure.timeout;
    } on SocketException {
      throw AppFailure.network;
    } on http.ClientException {
      throw AppFailure.network;
    } catch (e) {
      throw AppFailure(
        kind: AppFailureKind.api,
        userMessageAr: 'تعذر البحث عن المكان. حاول مرة أخرى.',
        debugMessage: e.toString(),
      );
    }
  }

  /// حساب مسافة المشي بالمتار عبر Google Directions API
  Future<int?> walkingDistanceMeters({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    if (!AppConfig.hasGooglePlaces) return null;

    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
        'origin': '$originLat,$originLng',
        'destination': '$destLat,$destLng',
        'mode': 'walking',
        'key': AppConfig.googleMapsApiKey,
      });
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['status'] != 'OK') return null;
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty) return null;
      final legs = (routes.first as Map<String, dynamic>)['legs'];
      if (legs is! List || legs.isEmpty) return null;
      final distance = (legs.first as Map<String, dynamic>)['distance'] as Map<String, dynamic>?;
      return (distance?['value'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }
}