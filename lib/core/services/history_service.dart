import '../../db/app_database.dart';
import '../models/hotel_price.dart';

class HistoryService {
  final AppDatabase _db;
  HistoryService(this._db);

  /// 儲存一輪查詢的所有飯店報價
  Future<void> saveResults({
    required String taskId,
    required List<HotelPrice> hotels,
    required String checkin,
    required String checkout,
    required DateTime polledAt,
  }) async {
    final entries = hotels
        .where((h) => h.price > 0) // 只儲存有報價的記錄
        .map(
          (h) => PriceHistoryTableCompanion.insert(
            taskId: taskId,
            hotelCode: h.code,
            hotelName: h.name,
            price: h.price,
            checkin: checkin,
            checkout: checkout,
            polledAt: polledAt,
          ),
        );
    for (final entry in entries) {
      await _db.insertHistory(entry);
    }
  }

  /// 取得某任務的價格時間序列，回傳 Map<hotelCode, [(timestamp, price)]>
  Future<Map<String, List<(DateTime, int)>>> getTimeSeries(
    String taskId,
  ) async {
    final rows = await _db.historyByTask(taskId);
    final result = <String, List<(DateTime, int)>>{};
    for (final row in rows) {
      result.putIfAbsent(row.hotelCode, () => []);
      result[row.hotelCode]!.add((row.polledAt, row.price));
    }
    return result;
  }

  /// 取得任務中所有出現過的飯店代碼
  Future<List<String>> hotelCodesForTask(String taskId) async {
    final rows = await _db.historyByTask(taskId);
    return rows.map((r) => r.hotelCode).toSet().toList();
  }

  Future<void> clearTask(String taskId) => _db.deleteTaskHistory(taskId);
}
