import 'dart:async';
import '../api/toyoko_api.dart';
import '../models/hotel_price.dart';
import '../models/poll_result.dart';
import '../models/search_params.dart';

/// 輪詢事件類型
enum PollerEventType { log, result, match, stopped, tick }

class PollerEvent {
  final PollerEventType type;
  final Object? data; // depends on type
  const PollerEvent(this.type, [this.data]);
}

/// 倒數計時 tick 資料
class TickData {
  final double elapsed;
  final double total;
  const TickData(this.elapsed, this.total);
}

/// 背景輪詢服務
/// 暴露 [events] Stream，由 Riverpod provider 監聽轉換為 UI state。
class PollerService {
  final ToyokoApi _api;
  final SearchParams params;
  final Map<String, String> hotelNames;

  final _controller = StreamController<PollerEvent>.broadcast();
  Stream<PollerEvent> get events => _controller.stream;

  bool _running = false;
  bool get running => _running;

  int _attempt = 0;

  PollerService({
    required this.params,
    required this.hotelNames,
    ToyokoApi? api,
  }) : _api = api ?? ToyokoApi();

  void start() {
    if (_running) return;
    _running = true;
    _attempt = 0;
    _runLoop();
  }

  void stop() {
    _running = false;
  }

  void dispose() {
    _running = false;
    _controller.close();
  }

  void _emit(PollerEventType type, [Object? data]) {
    if (!_controller.isClosed) {
      _controller.add(PollerEvent(type, data));
    }
  }

  Future<void> _runLoop() async {
    final startTime = DateTime.now();

    while (_running) {
      _attempt++;
      final nowStr = DateTime.now()
          .toString()
          .substring(11, 19); // HH:mm:ss

      // 停止條件檢查
      if (params.stopMode == 'attempts' && _attempt > params.stopValue) {
        _emit(PollerEventType.stopped, '已達最大嘗試次數 (${params.stopValue} 次)');
        _running = false;
        return;
      }
      if (params.stopMode == 'minutes') {
        final elapsedMin =
            DateTime.now().difference(startTime).inSeconds / 60.0;
        if (elapsedMin >= params.stopValue) {
          _emit(
            PollerEventType.stopped,
            '已達最大監控時間 (${params.stopValue} 分鐘)',
          );
          _running = false;
          return;
        }
      }

      _emit(PollerEventType.log, '\n[$nowStr]  第 $_attempt 次查詢');

      List<HotelPrice> hotels;
      try {
        hotels = await _api.fetchPrices(
          hotelCodes: params.hotelCodes,
          checkinDate: params.checkin,
          checkoutDate: params.checkout,
          numPeople: params.numPeople,
          numRooms: params.numRooms,
          smokingType: params.smokingType,
          hotelNames: hotelNames,
        );
      } catch (e) {
        _emit(PollerEventType.log, '  ❌ 請求錯誤: $e');
        final errResult = PollResult.error(
          attempt: _attempt,
          message: e.toString(),
        );
        _emit(PollerEventType.result, errResult);
        await _waitWithTick(params.intervalSec);
        continue;
      }

      final matches = <HotelPrice>[];
      for (final h in hotels) {
        if (h.available && h.price <= params.targetPrice) {
          _emit(PollerEventType.log, '  ⭐ ${h.name}: ${h.priceStr}  ← 符合目標!');
          matches.add(h);
        } else if (h.available) {
          _emit(PollerEventType.log, '  ✓  ${h.name}: ${h.priceStr}');
        } else if (h.price > 0 && !h.vacant) {
          _emit(PollerEventType.log, '  ⚠  ${h.name}: ${h.priceStr} (房間不足)');
        } else if (h.maintenance) {
          _emit(PollerEventType.log, '  🔧 ${h.name}: 維護中');
        } else {
          _emit(PollerEventType.log, '  ─  ${h.name}: 無空房');
        }
      }

      final result = PollResult(
        timestamp: DateTime.now(),
        attempt: _attempt,
        hotels: hotels,
        matches: matches,
      );
      _emit(PollerEventType.result, result);

      if (matches.isNotEmpty) {
        _emit(PollerEventType.match, matches);

        // stopMode='matches' 選項：找到 N 筆後停止
        if (params.stopMode == 'matches' && matches.length >= params.stopValue) {
          _emit(
            PollerEventType.stopped,
            '找到 ${matches.length} 筆符合條件，自動停止',
          );
          _running = false;
          return;
        }

        // 預設：找到後停止（stopMode='never' 的語意：直到找到）
        if (params.stopMode == 'never') {
          _emit(PollerEventType.stopped, '找到符合條件的飯店，停止監控');
          _running = false;
          return;
        }
      }

      _emit(
        PollerEventType.log,
        '  ⏳ 未找到符合條件，${params.intervalSec} 秒後重試...',
      );
      await _waitWithTick(params.intervalSec);
    }

    _emit(PollerEventType.stopped, '已手動停止');
  }

  /// 以 500ms 間隔等待，期間發送 tick 事件
  Future<void> _waitWithTick(int seconds) async {
    final total = seconds.toDouble();
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (_running) {
      final remaining = end.difference(DateTime.now()).inMilliseconds;
      if (remaining <= 0) break;
      final elapsed = total - remaining / 1000.0;
      _emit(PollerEventType.tick, TickData(elapsed, total));
      await Future.delayed(const Duration(milliseconds: 500));
    }
    _emit(PollerEventType.tick, TickData(0, total));
  }
}
