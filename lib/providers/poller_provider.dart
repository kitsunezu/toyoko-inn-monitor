import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/models/hotel_price.dart';
import '../core/models/poll_result.dart';
import '../core/models/search_params.dart';
import '../core/services/poller_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/history_service.dart';
import '../utils/url_utils.dart';
import 'settings_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final historyServiceProvider = Provider<HistoryService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

// ── Poller state ───────────────────────────────────────────────

class PollerState {
  final bool running;
  final List<PollResult> results;
  final List<String> logs;
  final List<HotelPrice> latestHotels;
  final List<HotelPrice> allMatches;
  final double tickElapsed;
  final double tickTotal;
  final String statusMsg;

  const PollerState({
    this.running = false,
    this.results = const [],
    this.logs = const [],
    this.latestHotels = const [],
    this.allMatches = const [],
    this.tickElapsed = 0,
    this.tickTotal = 1,
    this.statusMsg = '待命',
  });

  PollerState copyWith({
    bool? running,
    List<PollResult>? results,
    List<String>? logs,
    List<HotelPrice>? latestHotels,
    List<HotelPrice>? allMatches,
    double? tickElapsed,
    double? tickTotal,
    String? statusMsg,
  }) {
    return PollerState(
      running: running ?? this.running,
      results: results ?? this.results,
      logs: logs ?? this.logs,
      latestHotels: latestHotels ?? this.latestHotels,
      allMatches: allMatches ?? this.allMatches,
      tickElapsed: tickElapsed ?? this.tickElapsed,
      tickTotal: tickTotal ?? this.tickTotal,
      statusMsg: statusMsg ?? this.statusMsg,
    );
  }
}

class PollerNotifier extends Notifier<PollerState> {
  PollerService? _service;
  StreamSubscription<PollerEvent>? _sub;

  @override
  PollerState build() {
    ref.onDispose(disposeResources);
    return const PollerState();
  }

  void start(SearchParams params, Map<String, String> hotelNames) {
    _stopService();
    _service = PollerService(params: params, hotelNames: hotelNames);
    state = PollerState(running: true, statusMsg: '監控中...');

    _sub = _service!.events.listen(_onEvent);
    _service!.start();
  }

  void stop() {
    _service?.stop();
  }

  void clearLogs() {
    state = state.copyWith(logs: const []);
  }

  void clearAll() {
    state = const PollerState();
  }

  void _onEvent(PollerEvent event) {
    switch (event.type) {
      case PollerEventType.log:
        final newLogs = [...state.logs, event.data as String];
        // 最多保留 2000 行
        final trimmed =
            newLogs.length > 2000 ? newLogs.sublist(newLogs.length - 2000) : newLogs;
        state = state.copyWith(logs: trimmed);

      case PollerEventType.result:
        final result = event.data as PollResult;
        final newResults = [...state.results, result];
        state = state.copyWith(
          results: newResults,
          latestHotels: result.hotels,
        );
        // 儲存到資料庫（非同步，忽略錯誤）
        if (result.success && result.hotels.isNotEmpty) {
          _saveHistory(result);
        }

      case PollerEventType.match:
        final matches = event.data as List<HotelPrice>;
        final allMatches = [...state.allMatches, ...matches];
        state = state.copyWith(
          allMatches: allMatches,
          statusMsg: '找到了！',
        );
        _notifyMatches(matches);

      case PollerEventType.stopped:
        final reason = event.data as String;
        final notif = ref.read(notificationServiceProvider);
        notif.notifyStopped(reason);
        state = state.copyWith(
          running: false,
          statusMsg: reason,
          tickElapsed: 0,
          tickTotal: 1,
        );

      case PollerEventType.tick:
        final tick = event.data as TickData;
        state = state.copyWith(
          tickElapsed: tick.elapsed,
          tickTotal: tick.total,
        );
    }
  }

  void _saveHistory(PollResult result) {
    final hist = ref.read(historyServiceProvider);
    // taskId = '' for the single-task poller (main screen)
    hist
        .saveResults(
          taskId: '__main__',
          hotels: result.hotels,
          checkin: _service?.params.checkin ?? '',
          checkout: _service?.params.checkout ?? '',
          polledAt: result.timestamp,
        )
        .ignore();
  }

  void _notifyMatches(List<HotelPrice> matches) {
    final notif = ref.read(notificationServiceProvider);
    final params = _service?.params;
    if (params == null) return;

    final doNotification = ref.read(desktopNotificationProvider);
    final doOpenUrl = ref.read(autoOpenUrlProvider);

    final matchData = <({String name, int price, String url})>[];
    for (final h in matches) {
      final url = buildBookingUrl(
        hotelCode: h.code,
        checkin: params.checkin,
        checkout: params.checkout,
        rooms: params.numRooms,
        people: params.numPeople,
        smokingType: params.smokingType,
      );
      matchData.add((name: h.name, price: h.price, url: url));
      if (doOpenUrl) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).ignore();
      }
    }
    if (doNotification && matchData.isNotEmpty) {
      notif.notifyMatches(matches: matchData);
    }
  }

  void _stopService() {
    _sub?.cancel();
    _sub = null;
    _service?.dispose();
    _service = null;
  }

  void disposeResources() {
    _stopService();
  }
}

final pollerProvider = NotifierProvider<PollerNotifier, PollerState>(
  PollerNotifier.new,
);
