enum RoutePreference {
  fastest,
  fewestTransfers,

}

extension RoutePreferenceLabel on RoutePreference {
  String get labelAr {
    switch (this) {
      case RoutePreference.fastest:
        return 'الأسرع';
      case RoutePreference.fewestTransfers:
        return 'أقل تحويلات';

    }
  }

  String get labelEn {
    switch (this) {
      case RoutePreference.fastest:
        return 'Fastest';
      case RoutePreference.fewestTransfers:
        return 'Fewest Transfers';

    }
  }
}
