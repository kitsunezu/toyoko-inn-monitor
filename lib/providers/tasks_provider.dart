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
import 'settings_provider.dart';
import 'url_launcher_provider.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

typedef PollerServiceFactory =
    PollerService Function({
      required SearchParams params,
      required Map<String, String> hotelNames,
    });

final pollerServiceFactoryProvider = Provider<PollerServiceFactory>((ref) {
  return ({required params, required hotelNames}) =>
      PollerService(params: params, hotelNames: hotelNames);
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
    for (final row in rows.skip(1)) {
      await db.deleteTask(row.id);
    }
    final tasks = rows.take(1).map((row) {
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

  String _taskName(SearchParams params, String? customName) {
    final trimmed = customName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return '${params.location} ${params.checkin}-${params.checkout}';
  }

  /// 建立新任務並儲存到 DB
  Future<MonitorTask> createTask(
    SearchParams params,
    String? customName, {
    Map<String, String>? hotelNames,
  }) async {
    const uuid = Uuid();
    final id = uuid.v4();
    final name = _taskName(params, customName);
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

    for (final oldTask in state) {
      _stopPoller(oldTask.id);
      if (oldTask.id != id) await db.deleteTask(oldTask.id);
    }

    state = [task];
    if (hotelNames != null) {
      startTask(id, hotelNames);
      return state.firstWhere((task) => task.id == id);
    }

    return task;
  }

  Future<MonitorTask?> updateTask(
    String taskId,
    SearchParams params,
    String? customName, {
    Map<String, String>? hotelNames,
  }) async {
    final idx = state.indexWhere((t) => t.id == taskId);
    if (idx < 0) return null;

    final current = state[idx];
    final wasRunning =
        current.status == TaskStatus.running ||
        current.status == TaskStatus.matched;
    _stopPoller(taskId);

    final updated = MonitorTask(
      id: current.id,
      name: _taskName(params, customName),
      params: params,
      createdAt: current.createdAt,
      status: wasRunning && hotelNames == null
          ? TaskStatus.stopped
          : TaskStatus.idle,
    );

    final db = ref.read(dbProvider);
    await db.upsertTask(
      MonitorTaskTableCompanion.insert(
        id: updated.id,
        name: updated.name,
        paramsJson: jsonEncode(params.toJson()),
        createdAt: updated.createdAt,
      ),
    );

    state = [
      for (final task in state)
        if (task.id == taskId) updated else task,
    ];

    if (wasRunning && hotelNames != null) {
      startTask(taskId, hotelNames);
      return state.firstWhere((task) => task.id == taskId);
    }

    return updated;
  }

  void startTask(String taskId, Map<String, String> hotelNames) {
    final idx = state.indexWhere((t) => t.id == taskId);
    if (idx < 0) return;
    final task = state[idx];

    _stopPoller(taskId);

    final service = ref.read(pollerServiceFactoryProvider)(
      params: task.params,
      hotelNames: hotelNames,
    );
    _pollers[taskId] = service;
    _subs[taskId] = service.events.listen((evt) => _onEvent(taskId, evt));
    service.start();

    _updateStatus(
      taskId,
      TaskStatus.running,
      tickElapsed: 0,
      tickTotal: task.params.intervalSec.toDouble(),
    );
  }

  void stopTask(String taskId) {
    _stopPoller(taskId);
    _updateStatus(taskId, TaskStatus.stopped, tickElapsed: 0, tickTotal: 1);
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
          _handleSuccessfulResult(taskId, result).ignore();
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
        if (ref.read(autoOpenUrlProvider)) {
          final openExternalUrl = ref.read(externalUrlLauncherProvider);
          for (final match in matchData) {
            openExternalUrl(Uri.parse(match.url)).ignore();
          }
        }
        notif.notifyMatches(matches: matchData);

      case PollerEventType.stopped:
        _updateStatus(taskId, TaskStatus.stopped, tickElapsed: 0, tickTotal: 1);
        _stopPoller(taskId);

      case PollerEventType.tick:
        final tick = event.data as TickData;
        _updateTick(taskId, tick.elapsed, tick.total);

      default:
        break;
    }
  }

  void _updateStatus(
    String taskId,
    TaskStatus status, {
    double? tickElapsed,
    double? tickTotal,
  }) {
    state = [
      for (final t in state)
        if (t.id == taskId)
          t.copyWith(
            status: status,
            tickElapsed: tickElapsed,
            tickTotal: tickTotal,
          )
        else
          t,
    ];
  }

  void _updateTick(String taskId, double elapsed, double total) {
    state = [
      for (final t in state)
        if (t.id == taskId)
          t.copyWith(tickElapsed: elapsed, tickTotal: total)
        else
          t,
    ];
  }

  void _updateLatestPrices(
    String taskId,
    List<HotelPrice> hotels,
    DateTime polledAt,
    HotelPrice? lowestHotel,
  ) {
    state = [
      for (final t in state)
        if (t.id == taskId)
          t.copyWith(
            latestLowestPrice: lowestHotel?.price,
            lowestPriceHotel: lowestHotel,
            lastPolledAt: polledAt,
            latestHotelPrices: hotels,
          )
        else
          t,
    ];
  }

  Future<void> _handleSuccessfulResult(String taskId, PollResult result) async {
    final task = _taskById(taskId);
    if (task == null) return;

    final available = result.hotels.where((h) => h.available).toList();
    final lowestHotel = available.isEmpty
        ? null
        : available.reduce((a, b) => a.price < b.price ? a : b);

    try {
      await ref
          .read(historyServiceProvider)
          .saveResults(
            taskId: taskId,
            hotels: result.hotels,
            checkin: task.params.checkin,
            checkout: task.params.checkout,
            polledAt: result.timestamp,
          );
    } finally {
      _updateLatestPrices(taskId, result.hotels, result.timestamp, lowestHotel);
    }
  }

  MonitorTask? _taskById(String taskId) {
    for (final task in state) {
      if (task.id == taskId) return task;
    }
    return null;
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
