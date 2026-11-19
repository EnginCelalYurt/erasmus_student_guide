import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Live data model combining currency exchange (EUR/PLN) and Łódź campus weather.
class LodzLiveInfo {
  final double eurToPln;
  final double temperatureC;
  final DateTime lastUpdated;
  final bool isFromCache;
  final String? notice;

  const LodzLiveInfo({
    required this.eurToPln,
    required this.temperatureC,
    required this.lastUpdated,
    this.isFromCache = false,
    this.notice,
  });

  LodzLiveInfo copyWith({
    double? eurToPln,
    double? temperatureC,
    DateTime? lastUpdated,
    bool? isFromCache,
    String? notice,
  }) {
    return LodzLiveInfo(
      eurToPln: eurToPln ?? this.eurToPln,
      temperatureC: temperatureC ?? this.temperatureC,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isFromCache: isFromCache ?? this.isFromCache,
      notice: notice ?? this.notice,
    );
  }

  Map<String, dynamic> toJson() => {
        'eurToPln': eurToPln,
        'temperatureC': temperatureC,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory LodzLiveInfo.fromJson(Map<String, dynamic> json) => LodzLiveInfo(
        eurToPln: (json['eurToPln'] as num).toDouble(),
        temperatureC: (json['temperatureC'] as num).toDouble(),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        isFromCache: true,
      );
}

/// Week 7: API Integration & Offline Reliability Service.
/// Connects to real public APIs (NBP Currency Exchange & Open-Meteo Weather for Łódź).
/// Implements offline caching, clear loading/error states, and graceful fallback.
class LodzApiService {
  static const _cacheKey = 'erasmus_lodz_live_cache_v2';
  final HttpClient _client;

  LodzApiService({HttpClient? client}) : _client = client ?? HttpClient();

  /// Fetches live EUR/PLN and Łódź weather data.
  /// If network fails or times out, gracefully falls back to locally cached data with an 'isFromCache' flag.
  Future<LodzLiveInfo> fetchLiveInfo({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check cache first if not forced and less than 15 minutes old
    final cachedRaw = prefs.getString(_cacheKey);
    LodzLiveInfo? cachedInfo;
    if (cachedRaw != null) {
      try {
        cachedInfo = LodzLiveInfo.fromJson(jsonDecode(cachedRaw));
        final age = DateTime.now().difference(cachedInfo.lastUpdated);
        if (!forceRefresh && age.inMinutes < 15) {
          return cachedInfo;
        }
      } catch (_) {}
    }

    // 2. Perform live network requests
    try {
      final eurRate = await _fetchEurPlnRate();
      final tempC = await _fetchLodzTemperature();

      final liveInfo = LodzLiveInfo(
        eurToPln: eurRate,
        temperatureC: tempC,
        lastUpdated: DateTime.now(),
        isFromCache: false,
      );

      // Persist to local cache for offline reliability
      await prefs.setString(_cacheKey, jsonEncode(liveInfo.toJson()));
      return liveInfo;
    } catch (error) {
      // 3. Loss of connectivity or network failure fallback
      if (cachedInfo != null) {
        return cachedInfo.copyWith(
          isFromCache: true,
          notice: 'Offline mode: Showing cached data from ${_formatTime(cachedInfo.lastUpdated)}. Tap to retry.',
        );
      }

      // 4. Default fallback when no network and no cache exist
      return LodzLiveInfo(
        eurToPln: 4.32,
        temperatureC: 4.5,
        lastUpdated: DateTime.now(),
        isFromCache: true,
        notice: 'Offline demo data: Network unavailable and no previous cache found.',
      );
    }
  }

  /// NBP Public API: EUR to PLN exchange rate
  Future<double> _fetchEurPlnRate() async {
    final url = Uri.parse('https://api.nbp.pl/api/exchangerates/rates/a/eur/?format=json');
    final request = await _client.getUrl(url).timeout(const Duration(seconds: 5));
    request.headers.set('Accept', 'application/json');
    final response = await request.close().timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw HttpException('Failed with status code: ${response.statusCode}');
    }

    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final rates = data['rates'] as List;
    final mid = rates.first['mid'] as num;
    return mid.toDouble();
  }

  /// Open-Meteo Public API: Łódź Campus Temperature (Lat: 51.75, Lon: 19.45)
  Future<double> _fetchLodzTemperature() async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=51.75&longitude=19.45&current=temperature_2m',
    );
    final request = await _client.getUrl(url).timeout(const Duration(seconds: 5));
    final response = await request.close().timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw HttpException('Weather API status: ${response.statusCode}');
    }

    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final temp = current['temperature_2m'] as num;
    return temp.toDouble();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
