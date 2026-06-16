import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/core/models/hotel_price.dart';
import 'package:toyoko_inn_monitor/core/models/monitor_task.dart';
import 'package:toyoko_inn_monitor/core/models/search_params.dart';
import 'package:toyoko_inn_monitor/core/services/notification_service.dart';
import 'package:toyoko_inn_monitor/core/services/poller_service.dart';
import 'package:toyoko_inn_monitor/db/app_database.dart';
import 'package:toyoko_inn_monitor/providers/poller_provider.dart';
import 'package:toyoko_inn_monitor/providers/settings_provider.dart';
import 'package:toyoko_inn_monitor/providers/tasks_provider.dart';
import 'package:toyoko_inn_monitor/providers/url_launcher_provider.dart';
import 'package:toyoko_inn_monitor/utils/url_utils.dart';

void main() {
  group('TasksNotifier creation', () {
    test('starts a new task when hotel names are supplied', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final services = <_FakePollerService>[];
      final container = ProviderContainer(
        overrides: [
          dbProvider.overrideWithValue(db),
          pollerServiceFactoryProvider.overrideWithValue(({
            required params,
            required hotelNames,
          }) {
            final service = _FakePollerService(
              params: params,
              hotelNames: hotelNames,
            );
            services.add(service);
            return service;
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(tasksProvider);
      await Future<void>.delayed(Duration.zero);

      final created = await container
          .read(tasksProvider.notifier)
          .createTask(_params, 'Tokyo watch', hotelNames: _hotelNames);

      expect(created.status, TaskStatus.running);
      expect(container.read(tasksProvider).single.status, TaskStatus.running);
      expect(services, hasLength(1));
      expect(services.single.started, isTrue);
      expect(services.single.params, _params);
      expect(services.single.hotelNames, _hotelNames);
    });
  });

  group('TasksNotifier match handling', () {
    test('opens booking URL when auto-open is enabled', () async {
      final harness = _TaskHarness(autoOpen: true);
      addTearDown(harness.dispose);

      harness.start();
      harness.emitMatch(_hotel('00100', 4800));
      await Future<void>.delayed(Duration.zero);

      expect(harness.openedUrls.map((uri) => uri.toString()), [
        buildBookingUrl(
          hotelCode: '00100',
          checkin: '2026-07-01',
          checkout: '2026-07-02',
          rooms: 1,
          people: 2,
          smokingType: 'all',
        ),
      ]);
      expect(harness.task.status, TaskStatus.matched);
      expect(harness.notifications, hasLength(1));
    });

    test('does not open booking URL when auto-open is disabled', () async {
      final harness = _TaskHarness(autoOpen: false);
      addTearDown(harness.dispose);

      harness.start();
      harness.emitMatch(_hotel('00100', 4800));
      await Future<void>.delayed(Duration.zero);

      expect(harness.openedUrls, isEmpty);
      expect(harness.task.status, TaskStatus.matched);
      expect(harness.notifications, hasLength(1));
    });
  });
}

const _params = SearchParams(
  location: 'Tokyo',
  hotelCodes: ['00100'],
  checkin: '2026-07-01',
  checkout: '2026-07-02',
  numPeople: 2,
  smokingType: 'all',
  targetPrice: 5000,
  intervalSec: 15,
);

const _hotelNames = {'00100': 'Toyoko Inn 00100'};

class _TaskHarness {
  static final _task = MonitorTask(
    id: 'task-1',
    name: 'Tokyo watch',
    params: _params,
    createdAt: DateTime(2026, 6, 1),
  );

  final openedUrls = <Uri>[];
  final _notificationService = _RecordingNotificationService();
  late final ProviderContainer _container;
  _FakePollerService? _service;

  _TaskHarness({required bool autoOpen}) {
    _container = ProviderContainer(
      overrides: [
        tasksProvider.overrideWith(() => _FakeTasksNotifier([_task])),
        notificationServiceProvider.overrideWithValue(_notificationService),
        autoOpenUrlProvider.overrideWith((ref) => autoOpen),
        externalUrlLauncherProvider.overrideWithValue((uri) async {
          openedUrls.add(uri);
          return true;
        }),
        pollerServiceFactoryProvider.overrideWithValue(({
          required params,
          required hotelNames,
        }) {
          final service = _FakePollerService(
            params: params,
            hotelNames: hotelNames,
          );
          _service = service;
          return service;
        }),
      ],
    );
  }

  MonitorTask get task => _container.read(tasksProvider).single;

  List<List<({String name, int price, String url})>> get notifications =>
      _notificationService.notifications;

  void start() {
    _container.read(tasksProvider.notifier).startTask(_task.id, _hotelNames);
  }

  void emitMatch(HotelPrice hotel) {
    _service?.emit(PollerEvent(PollerEventType.match, [hotel]));
  }

  void dispose() {
    _container.read(tasksProvider.notifier).stopTask(_task.id);
    _container.dispose();
  }
}

class _FakeTasksNotifier extends TasksNotifier {
  final List<MonitorTask> initialTasks;

  _FakeTasksNotifier(this.initialTasks);

  @override
  List<MonitorTask> build() => initialTasks;
}

class _FakePollerService extends PollerService {
  final _events = StreamController<PollerEvent>.broadcast();
  bool _closed = false;
  bool started = false;

  _FakePollerService({required super.params, required super.hotelNames});

  @override
  Stream<PollerEvent> get events => _events.stream;

  @override
  void start() {
    started = true;
  }

  @override
  void stop() {}

  @override
  void dispose() {
    if (_closed) return;
    _closed = true;
    _events.close();
  }

  void emit(PollerEvent event) {
    if (!_closed) {
      _events.add(event);
    }
  }
}

class _RecordingNotificationService extends NotificationService {
  final notifications = <List<({String name, int price, String url})>>[];

  @override
  Future<void> notifyMatches({
    required List<({String name, int price, String url})> matches,
  }) async {
    notifications.add(matches);
  }

  @override
  Future<void> notifyStopped(String reason) async {}
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
