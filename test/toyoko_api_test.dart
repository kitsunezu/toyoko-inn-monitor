import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/core/api/toyoko_api.dart';

void main() {
  group('parseMemberRoomPlanPrice', () {
    test('uses the lowest matching member price with member stock', () {
      final hotel = parseMemberRoomPlanPrice(
        code: '00114',
        name: 'Ichinoseki',
        smokingType: 'noSmoking',
        html: _nextDataHtml([
          _room(isSmoking: true, plans: [_plan(price: 7000, vacant: 2)]),
          _room(
            isSmoking: false,
            plans: [
              _plan(price: 9595, vacant: 1),
              _plan(price: 8806, vacant: 1),
              _plan(price: 8170, vacant: 0),
            ],
          ),
        ]),
      );

      expect(hotel, isNotNull);
      expect(hotel!.code, '00114');
      expect(hotel.price, 8806);
      expect(hotel.available, isTrue);
    });

    test('does not use stock from the wrong smoking type', () {
      final hotel = parseMemberRoomPlanPrice(
        code: '00114',
        name: 'Ichinoseki',
        smokingType: 'smoking',
        html: _nextDataHtml([
          _room(isSmoking: false, plans: [_plan(price: 8806, vacant: 1)]),
        ]),
      );

      expect(hotel, isNull);
    });
  });
}

String _nextDataHtml(List<Map<String, Object?>> roomTypes) {
  final data = {
    'props': {
      'pageProps': {
        'planResponse': {'roomTypeList': roomTypes},
      },
    },
  };
  return '<script id="__NEXT_DATA__" type="application/json">'
      '${jsonEncode(data)}'
      '</script>';
}

Map<String, Object?> _room({
  required bool isSmoking,
  required List<Map<String, Object?>> plans,
}) {
  return {
    'specs': {'isSmoking': isSmoking},
    'plans': plans,
  };
}

Map<String, Object?> _plan({required int price, required int vacant}) {
  return {
    'price': {'membershipPrice': price},
    'vacant': {'membershipVacantRoom': vacant},
  };
}
