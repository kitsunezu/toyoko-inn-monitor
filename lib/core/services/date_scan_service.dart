import 'dart:async';
import '../api/toyoko_api.dart';
import '../../utils/date_utils.dart';

/// 日期範圍掃描結果：每天的最低價
class DateScanResult {
  final String date; // YYYY-MM-DD
  final int lowestPrice; // 0 = 無報價
  final String? hotelCode;
  final String? hotelName;

  const DateScanResult({
    required this.date,
    required this.lowestPrice,
    this.hotelCode,
    this.hotelName,
  });
}

/// 掃描指定日期範圍內每天的最低價
class DateScanService {
  final ToyokoApi _api;

  DateScanService({ToyokoApi? api}) : _api = api ?? ToyokoApi();

  /// 掃描 [startDate] 到 [endDate] 每天的最低價，並回傳串流。
  /// 每完成一天就 yield 一個 [DateScanResult]。
  Stream<DateScanResult> scan({
    required String startDate,
    required String endDate,
    required List<String> hotelCodes,
    required int nights,
    required int numPeople,
    int numRooms = 1,
    String smokingType = 'all',
    Map<String, String> hotelNames = const {},
    Duration delayBetweenDays = const Duration(milliseconds: 500),
  }) async* {
    final start = _parseDate(startDate);
    final end = _parseDate(endDate);

    var current = start;
    while (!current.isAfter(end)) {
      final checkin = formatDate(current);
      final checkout = formatDate(current.add(Duration(days: nights)));

      try {
        final hotels = await _api.fetchPrices(
          hotelCodes: hotelCodes,
          checkinDate: checkin,
          checkoutDate: checkout,
          numPeople: numPeople,
          numRooms: numRooms,
          smokingType: smokingType,
          hotelNames: hotelNames,
        );

        // 找當天最低有效報價
        final available = hotels.where((h) => h.available).toList();
        if (available.isEmpty) {
          yield DateScanResult(date: checkin, lowestPrice: 0);
        } else {
          available.sort((a, b) => a.price.compareTo(b.price));
          final best = available.first;
          yield DateScanResult(
            date: checkin,
            lowestPrice: best.price,
            hotelCode: best.code,
            hotelName: best.name,
          );
        }
      } catch (_) {
        yield DateScanResult(date: checkin, lowestPrice: -1); // -1 = 錯誤
      }

      current = current.add(const Duration(days: 1));
      await Future.delayed(delayBetweenDays);
    }
  }

  static DateTime _parseDate(String s) {
    final p = s.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }
}
