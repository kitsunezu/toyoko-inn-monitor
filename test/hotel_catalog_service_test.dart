import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/core/services/hotel_catalog_service.dart';
import 'package:toyoko_inn_monitor/data/locations.dart';

void main() {
  late Map<String, List<String>> originalLocations;
  late Map<String, String> originalNames;
  late Map<String, HotelLocationInfo> originalDetails;

  setUp(() {
    originalLocations = {
      for (final entry in kLocations.entries) entry.key: [...entry.value],
    };
    originalNames = {...kHotelNames};
    originalDetails = {...kHotelDetails};
  });

  tearDown(() {
    kLocations
      ..clear()
      ..addAll(originalLocations);
    kHotelNames
      ..clear()
      ..addAll(originalNames);
    kHotelDetails
      ..clear()
      ..addAll(originalDetails);
  });

  test('applies a valid runtime catalog', () {
    final count = applyHotelCatalogJson(_catalogJson(300));

    expect(count, 300);
    expect(kHotelNames, hasLength(300));
    expect(kLocations['Test location'], hasLength(300));
    expect(kHotelDetails['00000']?.address, 'Address 0');
  });

  test('rejects an undersized catalog without changing current data', () {
    final firstName = kHotelNames.values.first;

    expect(
      () => applyHotelCatalogJson(_catalogJson(299)),
      throwsFormatException,
    );
    expect(kHotelNames.values.first, firstName);
    expect(kHotelNames.length, originalNames.length);
  });
}

String _catalogJson(int count) => jsonEncode({
  'hotels': [
    for (var i = 0; i < count; i++)
      {
        'code': i.toString().padLeft(5, '0'),
        'name': 'Hotel $i',
        'region': 'Test region',
        'prefecture': 'Test prefecture',
        'appLocation': 'Test location',
        'address': 'Address $i',
        'phone': 'Phone $i',
        'status': '',
      },
  ],
});
