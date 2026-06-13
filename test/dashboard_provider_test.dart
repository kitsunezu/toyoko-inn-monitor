import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/core/models/hotel_price.dart';
import 'package:toyoko_inn_monitor/core/models/monitor_task.dart';
import 'package:toyoko_inn_monitor/core/models/search_params.dart';
import 'package:toyoko_inn_monitor/core/services/history_service.dart';
import 'package:toyoko_inn_monitor/db/app_database.dart';
import 'package:toyoko_inn_monitor/providers/dashboard_provider.dart';
import 'package:toyoko_inn_monitor/providers/poller_provider.dart';
import 'package:toyoko_inn_monitor/providers/tasks_provider.dart';

void main() {
  group('buildDashboardSummary', () {
    test('returns empty defaults when no monitor tasks exist', () {
      final summary = buildDashboardSummary(
        tasks: const [],
        sessionMatches: const [],
        now: DateTime(2026, 6, 12),
      );

      expect(summary.lowestPrice, isNull);
      expect(summary.targetHitRate, 0);
      expect(summary.totalTasks, 0);
      expect(summary.activeTasks, 0);
      expect(summary.alertsToday, 0);
      expect(summary.pollIntervalSec, 15);
    });

    test('computes prices, status counts, hit rate, and alerts', () {
      final now = DateTime(2026, 6, 12, 10, 30);
      final tasks = [
        _task(
          id: 'running-hit',
          status: TaskStatus.running,
          latestLowestPrice: 4800,
          targetPrice: 5000,
          lastPolledAt: now,
        ),
        _task(
          id: 'matched',
          status: TaskStatus.matched,
          latestLowestPrice: 6200,
          targetPrice: 6000,
          lastPolledAt: now,
          matchedHotels: [_hotel('00100', 6200)],
        ),
        _task(id: 'paused', status: TaskStatus.stopped, targetPrice: 7000),
      ];

      final summary = buildDashboardSummary(
        tasks: tasks,
        sessionMatches: [_hotel('00200', 4500)],
        now: now,
      );

      expect(summary.lowestPrice, 4800);
      expect(summary.targetHitRate, 0.5);
      expect(summary.totalTasks, 3);
      expect(summary.runningTasks, 2);
      expect(summary.pausedTasks, 1);
      expect(summary.alertTasks, 1);
      expect(summary.alertsToday, 2);
      expect(summary.pollIntervalSec, 15);
    });

    test('excludes monitor-only tasks from target hit rate', () {
      final tasks = [
        _task(id: 'monitor-only', latestLowestPrice: 3200, targetPrice: null),
        _task(id: 'target-hit', latestLowestPrice: 4800, targetPrice: 5000),
        _task(id: 'target-miss', latestLowestPrice: 6200, targetPrice: 6000),
      ];

      final summary = buildDashboardSummary(
        tasks: tasks,
        sessionMatches: const [],
      );

      expect(summary.lowestPrice, 3200);
      expect(summary.targetHitRate, 0.5);
      expect(summary.totalTasks, 3);
    });
  });

  group('buildDashboardAlerts', () {
    test('normalizes task and live monitor matches newest first', () {
      final older = DateTime(2026, 6, 12, 9);
      final newer = DateTime(2026, 6, 12, 10);
      final alerts = buildDashboardAlerts(
        tasks: [
          _task(
            id: 'task',
            status: TaskStatus.matched,
            targetPrice: 5000,
            lastPolledAt: older,
            matchedHotels: [_hotel('00100', 5600)],
          ),
        ],
        sessionMatches: [_hotel('00200', 4800)],
        sessionTimestamp: newer,
      );

      expect(alerts, hasLength(2));
      expect(alerts.first.taskName, 'Live monitor');
      expect(alerts.first.severity, DashboardAlertSeverity.low);
      expect(alerts.last.severity, DashboardAlertSeverity.high);
    });
  });

  group('taskHistoryProvider', () {
    test('loads ordered time series from the history service', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final service = HistoryService(db);
      final first = DateTime(2026, 6, 12, 9);
      final second = DateTime(2026, 6, 12, 10);

      await service.saveResults(
        taskId: 'task-1',
        hotels: [_hotel('00100', 5100)],
        checkin: '2026-07-01',
        checkout: '2026-07-02',
        polledAt: second,
      );
      await service.saveResults(
        taskId: 'task-1',
        hotels: [_hotel('00100', 4900)],
        checkin: '2026-07-01',
        checkout: '2026-07-02',
        polledAt: first,
      );

      final container = ProviderContainer(
        overrides: [
          historyServiceProvider.overrideWithValue(service),
          tasksProvider.overrideWith(
            () => _FakeTasksNotifier(const []) as TasksNotifier,
          ),
        ],
      );
      addTearDown(container.dispose);

      final series = await container.read(taskHistoryProvider('task-1').future);

      expect(series.keys, contains('00100'));
      expect(series['00100']!.map((point) => point.$2), [4900, 5100]);
    });

    test('reloads when the task receives a new poll timestamp', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final service = HistoryService(db);
      final polledAt = DateTime(2026, 6, 12, 11);
      late _FakeTasksNotifier tasks;

      final container = ProviderContainer(
        overrides: [
          historyServiceProvider.overrideWithValue(service),
          tasksProvider.overrideWith(() {
            tasks = _FakeTasksNotifier([_task(id: 'task-1')]);
            return tasks as TasksNotifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(
        taskHistoryProvider('task-1').future,
      );
      expect(initial, isEmpty);

      await service.saveResults(
        taskId: 'task-1',
        hotels: [_hotel('00100', 5200)],
        checkin: '2026-07-01',
        checkout: '2026-07-02',
        polledAt: polledAt,
      );

      tasks.setTasks([_task(id: 'task-1', lastPolledAt: polledAt)]);

      final series = await container.read(taskHistoryProvider('task-1').future);

      expect(series.keys, contains('00100'));
      expect(series['00100']!.map((point) => point.$2), [5200]);
    });
  });
}

class _FakeTasksNotifier extends TasksNotifier {
  final List<MonitorTask> initialTasks;

  _FakeTasksNotifier(this.initialTasks);

  @override
  List<MonitorTask> build() => initialTasks;

  void setTasks(List<MonitorTask> tasks) {
    state = tasks;
  }
}

MonitorTask _task({
  required String id,
  TaskStatus status = TaskStatus.idle,
  int? latestLowestPrice,
  int? targetPrice = 5000,
  DateTime? lastPolledAt,
  List<HotelPrice> matchedHotels = const [],
}) {
  return MonitorTask(
    id: id,
    name: 'Monitor $id',
    params: SearchParams(
      location: 'Tokyo',
      hotelCodes: const ['00100'],
      checkin: '2026-07-01',
      checkout: '2026-07-02',
      numPeople: 2,
      targetPrice: targetPrice,
      intervalSec: 15,
    ),
    status: status,
    latestLowestPrice: latestLowestPrice,
    lowestPriceHotel: latestLowestPrice == null
        ? null
        : _hotel('00100', latestLowestPrice),
    createdAt: DateTime(2026, 6, 1),
    lastPolledAt: lastPolledAt,
    matchedHotels: matchedHotels,
  );
}

HotelPrice _hotel(String code, int price) {
  return HotelPrice(
    code: code,
    name: 'Toyoko Inn $code',
    price: price,
    vacant: true,
    maintenance: false,
  );
}
