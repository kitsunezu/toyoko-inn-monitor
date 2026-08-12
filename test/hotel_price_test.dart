import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/core/models/hotel_price.dart';

void main() {
  test('records the unavailable dates from nightly prices', () {
    final stay = _price(price: 0, vacant: false).withNightlyAvailability(
      stayDates: const ['2026-09-01', '2026-09-02', '2026-09-03'],
      nightlyPrices: [
        _price(price: 7000, vacant: true),
        _price(price: 0, vacant: false),
        _price(price: 7200, vacant: true),
      ],
    );

    expect(stay.nightlyAvailabilityChecked, isTrue);
    expect(stay.unavailableDates, ['2026-09-02']);
  });

  test('distinguishes a continuous-stay failure from a missing night', () {
    final stay = _price(price: 0, vacant: false).withNightlyAvailability(
      stayDates: const ['2026-09-01', '2026-09-02'],
      nightlyPrices: [
        _price(price: 7000, vacant: true),
        _price(price: 7200, vacant: true),
      ],
    );

    expect(stay.nightlyAvailabilityChecked, isTrue);
    expect(stay.unavailableDates, isEmpty);
  });
}

HotelPrice _price({required int price, required bool vacant}) {
  return HotelPrice(
    code: '00100',
    name: 'Tokyo',
    price: price,
    vacant: vacant,
    maintenance: false,
  );
}
