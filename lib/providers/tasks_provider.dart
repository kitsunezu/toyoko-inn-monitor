import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/models/monitor_task.dart';
import '../core/models/poll_result.dart';
import '../core/models/search_params.dart';
import '../core/models/hotel_price.dart';
import '../core/services/poller_service.dart';
import '../db/app_database.dart';
import '../utils/url_utils.dart';
import 'poller_provider.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

class TasksNotifier extends Notifier<List<MonitorTask>> {
  final _pollers = <String, PollerService>{};
  final _subs = <String, StreamSubscription<PollerEvent>>{};

  @override
  List<MonitorTask> build() {
    _loadFromDb();
    return [];
  }

  Future<void> _loadFromDb() async {
    final db = ref.read(dbProvider);
    final rows = await db.allTasks();
    final tasks = rows.map((row) {
      final params = SearchParams.fromJson(
        jsonDecode(row.paramsJson) as Map<String, dynamic>,
      );
      return MonitorTask(
        id: row.id,
        name: row.name,
        params: params,
        createdAt: row.createdAt,
      );
    }).toList();
    state = tasks;
  }

  /// 建立新任務並儲存到 DB
  Future<MonitorTask> createTask(
    SearchParams params,
    String? customName,
  ) async {
    const uuid = Uuid();
    final id = uuid.v4();
    final name =
        customName ??
        '${params.location} ${params.checkin}→${params.checkout}';
    final task = MonitorTask(
      id: id,
      name: name,
      params: params,
      createdAt: DateTime.now(),
    );

    final db = ref.read(dbProvider);
    await db.upsertTask(
      MonitorTaskTableCompanion.insert(
        id: id,
        name: name,
        paramsJson: jsonEncode(params.toJson()),
        createdAt: task.createdAt,
      ),
    );

    state = [...state, task];
    return task;
  }

  void startTask(String taskId, Map<String, String> hotelNames) {
    final idx = state.indexWhere((t) => t.id == taskId);
    if (idx < 0) return;
    final task = state[idx];

    _stopPoller(taskId);

    final service = PollerService(
      params: task.params,
      hotelNames: hotelNames,
    );
    _pollers[taskId] = service;
    _subs[taskId] = service.events.listen((evt) => _onEvent(taskId, evt));
    service.start();

    _updateStatus(taskId, TaskStatus.running);
  }

  void stopTask(String taskId) {
    _stopPoller(taskId);
    _updateStatus(taskId, TaskStatus.stopped);
  }

  Future<void> deleteTask(String taskId) async {
    _stopPoller(taskId);
    final db = ref.read(dbProvider);
    await db.deleteTask(taskId);
    state = state.where((t) => t.id != taskId).toList();
  }

  void _onEvent(String taskId, PollerEvent event) {
    switch (event.type) {
      case PollerEventType.result:
        final result = event.data as PollResult;
        if (result.success && result.hotels.isNotEmpty) {
          final available = result.hotels.where((h) => h.available).toList();
          if (available.isNotEmpty) {
            final lowestHotel =
                available.reduce((a, b) => a.price < b.price ? a : b);
            _updateLatestPrice(
              taskId,
              lowestHotel.price,
              DateTime.now(),
              lowestHotel,
            );
          }

          final hist = ref.read(historyServiceProvider);
          final task = state.firstWhere(
            (t) => t.id == taskId,
            orElse: () => state.first,
          );
          hist
              .saveResults(
                taskId: taskId,
                hotels: result.hotels,
                checkin: task.params.checkin,
                checkout: task.params.checkout,
                polledAt: result.timestamp,
              )
              .ignore();
        }

      case PollerEventType.match:
        final matches = event.data as List<HotelPrice>;
        final task = state.firstWhere(
          (t) => t.id == taskId,
          orElse: () => state.first,
        );
        // Store matched hotels + update status in one go
        state = [
          for (final t in state)
            if (t.id == taskId)
              t.copyWith(status: TaskStatus.matched, matchedHotels: matches)
            else
              t,
        ];
        // Single notification listing all matched hotels
        final notif = ref.read(notificationServiceProvider);
        final matchData = matches
            .map(
              (h) => (
                name: h.name,
                price: h.price,
                url: buildBookingUrl(
                  hotelCode: h.code,
                  checkin: task.params.checkin,
                  checkout: task.params.checkout,
                  rooms: task.params.numRooms,
                  people: task.params.numPeople,
                  smokingType: task.params.smokingType,
                ),
              ),
            )
            .toList();
        notif.notifyMatches(matches: matchData);

      case PollerEventType.stopped:
        _updateStatus(taskId, TaskStatus.stopped);
        _stopPoller(taskId);

      default:
        break;
    }
  }

  void _updateStatus(String taskId, TaskStatus status) {
    state = [
      for (final t in state)
        if (t.id == taskId) t.copyWith(status: status) else t,
    ];
  }

  void _updateLatestPrice(
    String taskId,
    int price,
    DateTime polledAt,
    HotelPrice lowestHotel,
  ) {
    state = [
      for (final t in state)
        if (t.id == taskId)
          t.copyWith(
            latestLowestPrice: price,
            lowestPriceHotel: lowestHotel,
            lastPolledAt: polledAt,
          )
        else
          t,
    ];
  }

  void _stopPoller(String taskId) {
    _subs[taskId]?.cancel();
    _subs.remove(taskId);
    _pollers[taskId]?.dispose();
    _pollers.remove(taskId);
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, List<MonitorTask>>(
  TasksNotifier.new,
);
