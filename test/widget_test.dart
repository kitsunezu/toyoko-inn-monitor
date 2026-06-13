import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/core/models/monitor_task.dart';
import 'package:toyoko_inn_monitor/core/models/search_params.dart';
import 'package:toyoko_inn_monitor/db/app_database.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:toyoko_inn_monitor/providers/tasks_provider.dart';
import 'package:toyoko_inn_monitor/ui/dashboard/dashboard_page.dart';
import 'package:toyoko_inn_monitor/ui/dashboard/dashboard_style.dart';
import 'package:toyoko_inn_monitor/ui/dashboard/monitor_task_table.dart';
import 'package:toyoko_inn_monitor/utils/app_theme.dart';

void main() {
  testWidgets('dashboard page renders focused monitor panels in English', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await _pumpDashboard(tester, db, const Locale('en'));
    final l = _l10n(tester);

    expect(find.text(l.dashboardNavActiveMonitors), findsOneWidget);
    expect(find.text(l.dashboardNoMonitorTasks), findsWidgets);
    expect(find.text(l.btnAddTask), findsOneWidget);
    expect(find.text(l.dashboardPriceTrend), findsOneWidget);
    expect(find.text(l.dashboardNoTaskSelected), findsWidgets);
    expect(find.text(l.dashboardAlertFeed), findsOneWidget);
  });

  testWidgets('dashboard page renders localized Chinese and Japanese labels', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await _pumpDashboard(tester, db, const Locale('zh'));
    final zh = _l10n(tester);

    expect(find.text(zh.dashboardNavActiveMonitors), findsOneWidget);
    expect(find.text(zh.dashboardNoMonitorTasks), findsWidgets);
    expect(find.text(zh.dashboardPriceTrend), findsOneWidget);

    await _pumpDashboard(tester, db, const Locale('ja'));
    final ja = _l10n(tester);

    expect(find.text(ja.dashboardNavActiveMonitors), findsOneWidget);
    expect(find.text(ja.dashboardNoMonitorTasks), findsWidgets);
    expect(find.text(ja.dashboardPriceTrend), findsOneWidget);
  });

  testWidgets('active monitor panel enables brand beam while running', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        child: SizedBox(
          width: 720,
          height: 800,
          child: ActiveMonitorPanel(task: _task(status: TaskStatus.running)),
        ),
      ),
    );

    final runningBeam = tester.widget<DashboardBeamFrame>(
      find.byType(DashboardBeamFrame),
    );
    expect(runningBeam.enabled, isTrue);

    await tester.pumpWidget(
      _testApp(
        child: SizedBox(
          width: 720,
          height: 800,
          child: ActiveMonitorPanel(task: _task(status: TaskStatus.stopped)),
        ),
      ),
    );

    final stoppedBeam = tester.widget<DashboardBeamFrame>(
      find.byType(DashboardBeamFrame),
    );
    expect(stoppedBeam.enabled, isFalse);
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester,
  AppDatabase db,
  Locale locale,
) async {
  await tester.pumpWidget(
    _testApp(
      locale: locale,
      overrides: [dbProvider.overrideWithValue(db)],
      child: const SizedBox(width: 1280, height: 800, child: DashboardPage()),
    ),
  );
}

Widget _testApp({
  required Widget child,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.dark,
      home: Scaffold(body: child),
    ),
  );
}

MonitorTask _task({TaskStatus status = TaskStatus.idle}) {
  return MonitorTask(
    id: 'task-1',
    name: 'Tokyo Weekend',
    params: const SearchParams(
      location: 'Tokyo',
      hotelCodes: ['00100'],
      checkin: '2026-07-01',
      checkout: '2026-07-02',
      numPeople: 2,
      targetPrice: 5000,
      intervalSec: 15,
    ),
    status: status,
    createdAt: DateTime(2026, 6, 13),
  );
}

AppLocalizations _l10n(WidgetTester tester) {
  final context = tester.element(find.byType(DashboardPage));
  return AppLocalizations.of(context)!;
}
