import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/locations.dart';

const hotelCatalogDownloadUrl =
    'https://raw.githubusercontent.com/kitsunezu/toyoko-inn-monitor/main/assets/hotel_catalog.json';

class HotelCatalogService {
  HotelCatalogService({Dio? dio}) : _dio = dio ?? Dio();

  static const _catalogKey = 'toyoko_hotel_catalog_json';
  static const _updatedAtKey = 'toyoko_hotel_catalog_updated_at';

  final Dio _dio;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getString(_catalogKey);
    if (saved == null) return;
    try {
      applyHotelCatalogJson(saved);
    } on FormatException {
      await _prefs.remove(_catalogKey);
      await _prefs.remove(_updatedAtKey);
    }
  }

  DateTime? get updatedAt {
    final value = _prefs.getString(_updatedAtKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<int> update() async {
    final response = await _dio.get<String>(
      hotelCatalogDownloadUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final raw = response.data;
    if (raw == null || raw.isEmpty) {
      throw const FormatException('Downloaded hotel catalog is empty.');
    }
    final count = applyHotelCatalogJson(raw);
    final now = DateTime.now();
    await _prefs.setString(_catalogKey, raw);
    await _prefs.setString(_updatedAtKey, now.toIso8601String());
    return count;
  }
}

int applyHotelCatalogJson(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic> || decoded['hotels'] is! List) {
    throw const FormatException('Invalid hotel catalog format.');
  }

  final hotels = (decoded['hotels'] as List).cast<Object?>();
  if (hotels.length < 300) {
    throw FormatException('Hotel catalog has only ${hotels.length} hotels.');
  }

  final locations = <String, List<String>>{};
  final names = <String, String>{};
  final details = <String, HotelLocationInfo>{};
  for (final value in hotels) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid hotel entry.');
    }
    final code = value['code'];
    final name = value['name'];
    final location = value['appLocation'];
    if (code is! String ||
        !RegExp(r'^\d{5}$').hasMatch(code) ||
        name is! String ||
        name.isEmpty ||
        location is! String ||
        location.isEmpty ||
        names.containsKey(code)) {
      throw const FormatException('Invalid or duplicate hotel entry.');
    }
    names[code] = name;
    locations.putIfAbsent(location, () => <String>[]).add(code);
    details[code] = HotelLocationInfo(
      name: name,
      region: value['region'] as String? ?? '',
      prefecture: value['prefecture'] as String? ?? '',
      address: value['address'] as String? ?? '',
      phone: value['phone'] as String? ?? '',
      status: value['status'] as String? ?? '',
    );
  }

  kLocations
    ..clear()
    ..addAll(locations);
  kHotelNames
    ..clear()
    ..addAll(names);
  kHotelDetails
    ..clear()
    ..addAll(details);
  return hotels.length;
}
