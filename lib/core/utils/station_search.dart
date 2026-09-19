import '../../data/metro_data.dart';
import '../../data/models/metro_station.dart';

abstract final class StationSearch {
  const StationSearch._();

  // Cached Compiled RegExps لمنع إعادة الإنشاء على الـ Memory
  static final RegExp _regexNonAlphaNum = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final RegExp _regexSpaces = RegExp(r'\s+');
  static final RegExp _regexArabicDiacritics = RegExp(r'[\u064B-\u0652]');
  static final RegExp _regexAlef = RegExp(r'[أإآ]');

  static List<MetroStation> search(String query) {
    final rawQuery = query.trim().toLowerCase();
    if (rawQuery.isEmpty) {
      return List<MetroStation>.unmodifiable(MetroData.stations);
    }

    final normalizedQuery = _normalize(rawQuery);
    if (normalizedQuery.isEmpty) return const [];

    // استخدام Set Literal لمنع التكرار والحفاظ على الترتيب بدون تحذير Linter
    final resultSet = <MetroStation>{};
    final fuzzy = <MetroStation>[];

    final isFuzzyEligible = normalizedQuery.length >= 3;

    for (final station in MetroData.stations) {
      final en = station.nameEn.toLowerCase();
      final ar = station.nameAr.toLowerCase();
      final enNorm = _normalize(en);
      final arNorm = _normalize(ar);

      // 1. Exact Match
      if (en == rawQuery || ar == rawQuery || enNorm == normalizedQuery || arNorm == normalizedQuery) {
        resultSet.add(station);
        continue;
      }

      // 2. StartsWith Match
      if (en.startsWith(rawQuery) ||
          ar.startsWith(rawQuery) ||
          enNorm.startsWith(normalizedQuery) ||
          arNorm.startsWith(normalizedQuery)) {
        resultSet.add(station);
        continue;
      }

      // 3. Contains Match
      if (en.contains(rawQuery) ||
          ar.contains(rawQuery) ||
          enNorm.contains(normalizedQuery) ||
          arNorm.contains(normalizedQuery)) {
        resultSet.add(station);
        continue;
      }

      // 4. Fuzzy Match (فقط لو الكلمة 3 حروف فأكثر)
      if (isFuzzyEligible && !resultSet.contains(station)) {
        final enTokens = enNorm.split(' ');
        final arTokens = arNorm.split(' ');

        final closeToName = _levenshtein(enNorm, normalizedQuery) <= 2 ||
            _levenshtein(arNorm, normalizedQuery) <= 2;

        final closeToToken = enTokens.any((t) => t.length >= 3 && _levenshtein(t, normalizedQuery) <= 1) ||
            arTokens.any((t) => t.length >= 3 && _levenshtein(t, normalizedQuery) <= 1);

        if (closeToName || closeToToken) {
          fuzzy.add(station);
        }
      }
    }

    return [...resultSet, ...fuzzy];
  }

  /// تطهير وتوحيد النصوص باللغتين العربية والإنجليزية
  static String _normalize(String value) {
    var result = value.replaceAll(_regexArabicDiacritics, '');
    
    // توحيد الألف والهمزات والتاء المربوطة بالعربية
    result = result
        .replaceAll(_regexAlef, 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');

    result = result.replaceAll(_regexNonAlphaNum, ' ').replaceAll(_regexSpaces, ' ');
    return result.trim();
  }

  /// Levenshtein Distance خفيفة ومحسّنة
  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final m = a.length;
    final n = b.length;

    var prev = List<int>.generate(n + 1, (i) => i, growable: false);
    var curr = List<int>.filled(n + 1, 0, growable: false);

    for (var i = 1; i <= m; i++) {
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        final subCost = prev[j - 1] + cost;
        final delCost = prev[j] + 1;
        final insCost = curr[j - 1] + 1;

        int min = subCost < delCost ? subCost : delCost;
        curr[j] = min < insCost ? min : insCost;
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[n];
  }
}