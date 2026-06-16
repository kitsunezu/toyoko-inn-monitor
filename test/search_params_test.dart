import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/core/models/search_params.dart';
import 'package:toyoko_inn_monitor/utils/url_utils.dart';

void main() {
  group('SearchParams smoking type', () {
    test('defaults to all when missing from saved json', () {
      final params = SearchParams.fromJson({
        'location': 'Tokyo',
        'hotelCodes': ['00100'],
        'checkin': '2026-07-01',
        'checkout': '2026-07-02',
      });

      expect(params.smokingType, 'all');
    });

    test('keeps all in booking urls', () {
      final url = buildBookingUrl(
        hotelCode: '00100',
        checkin: '2026-07-01',
        checkout: '2026-07-02',
        smokingType: 'all',
      );

      expect(url, contains('smoking=all'));
    });
  });
}
