import 'package:flutter/foundation.dart';

@immutable
abstract class AppConfig {
  const AppConfig._();


  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');


  static  bool hasGooglePlaces = googleMapsApiKey.isNotEmpty;
}