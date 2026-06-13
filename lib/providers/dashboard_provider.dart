import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/hotel_price.dart';
import '../core/models/monitor_task.dart';
import 'poller_provider.dart';
import 'tasks_provider.dart';

class DashboardSummary {
  final int? lowestPrice;
  final double targetHitRate;
  final int activeTasks;
  final int totalTasks;
  final int runningTasks;
  final int pausedTasks;
  final int alertTasks;
  final int alertsToday;
  final DateTime? lastUpdated;
  final int pollIntervalSec;

  const DashboardSummary({
    required this.lowestPrice,
    required this.targetHitRate,
    required this.activeTasks,
    required this.totalTasks,
    required this.runningTasks,
    required this.pausedTasks,
    required this.alertTasks,
    required this.alertsToday,
    required this.lastUpdated,
    required this.pollIntervalSec,
  });
}

enum DashboardAlertSeverity { high, medium, low }

class DashboardAlertItem {
  final String id;
  final String title;
  final String taskName;
  final String hotelName;
  final int price;
  final int? targetPrice;
  final DateTime timestamp;
  final DashboardAlertSeverity severity;

  const DashboardAlertItem({
    required this.id,
    required this.title,
    required this.taskName,
    required this.hotelName,
    required this.price,
    required this.targetPrice,
    required this.timestamp,
    required this.severity,
  });
}

DashboardSummary buildDashboardSummary({
  required List<MonitorTask> tasks,
  required List<HotelPrice> sessionMatches,
  DateTime? now,
}) {
  final pricedTasks = tasks.where((task) => task.latestLowestPrice != null);
  final lowest = pricedTasks.fold<int?>(null, (min, task) {
    final price = task.latestLowestPrice;
    if (price == null) return min;
    return min == null || price < min ? price : min;
  });

  final targetChecked = pricedTasks
      .where((task) => task.params.targetPrice != null)
      .toList();
  final targetHits = targetChecked
      .where((task) => task.latestLowestPrice! <= task.params.targetPrice!)
      .length;
  final hitRate = targetChecked.isEmpty
      ? 0.0
      : targetHits / targetChecked.length;

  final running = tasks
      .where(
        (task) =>
            task.status == TaskStatus.running ||
            task.status == TaskStatus.matched,
      )
      .length;
  final alert = tasks.where((task) => task.status == TaskStatus.matched).length;
  final paused = tasks
      .where(
        (task) =>
            task.status == TaskStatus.stopped || task.status == TaskStatus.idle,
      )
      .length;
  final lastUpdated = tasks.fold<DateTime?>(null, (latest, task) {
    final polledAt = task.lastPolledAt;
    if (polledAt == null) return latest;
    return latest == null || polledAt.isAfter(latest) ? polledAt : latest;
  });

  final today = now ?? DateTime.now();
  final todayTaskAlerts = tasks.fold<int>(0, (count, task) {
    final polledAt = task.lastPolledAt;
    final isToday =
        polledAt != null &&
        polledAt.year == today.year &&
        polledAt.month == today.month &&
        polledAt.day == today.day;
    if (!isToday) return count;
    return count + task.matchedHotels.length;
  });

  final pollInterval = tasks
      .where((task) => task.status == TaskStatus.running)
      .fold<int?>(null, (min, task) {
        final interval = task.params.intervalSec;
        return min == null || interval < min ? interval : min;
      });

  return DashboardSummary(
    lowestPrice: lowest,
    targetHitRate: hitRate,
    activeTasks: running,
    totalTasks: tasks.length,
    runningTasks: running,
    pausedTasks: paused,
    alertTasks: alert,
    alertsToday: todayTaskAlerts + sessionMatches.length,
    lastUpdated: lastUpdated,
    pollIntervalSec: pollInterval ?? 15,
  );
}

List<DashboardAlertItem> buildDashboardAlerts({
  required List<MonitorTask> tasks,
  required List<HotelPrice> sessionMatches,
  DateTime? sessionTimestamp,
}) {
  final alerts = <DashboardAlertItem>[];

  for (final task in tasks) {
    for (final hotel in task.matchedHotels) {
      final targetPrice = task.params.targetPrice;
      final severity = targetPrice == null
          ? DashboardAlertSeverity.low
          : _severityFor(hotel.price, targetPrice);
      alerts.add(
        DashboardAlertItem(
          id: '${task.id}-${hotel.code}-${hotel.price}',
          title: _alertTitle(severity),
          taskName: task.name,
          hotelName: hotel.name,
          price: hotel.price,
          targetPrice: targetPrice,
          timestamp: task.lastPolledAt ?? DateTime.now(),
          severity: severity,
        ),
      );
    }
  }

  final timestamp = sessionTimestamp ?? DateTime.now();
  for (final hotel in sessionMatches) {
    alerts.add(
      DashboardAlertItem(
        id: '__main__-${hotel.code}-${hotel.price}',
        title: 'Target hit',
        taskName: 'Live monitor',
        hotelName: hotel.name,
        price: hotel.price,
        targetPrice: null,
        timestamp: timestamp,
        severity: DashboardAlertSeverity.low,
      ),
    );
  }

  alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return alerts;
}

DashboardAlertSeverity _severityFor(int price, int targetPrice) {
  if (price <= targetPrice) return DashboardAlertSeverity.low;
  final ratio = price / targetPrice;
  if (ratio <= 1.1) return DashboardAlertSeverity.medium;
  return DashboardAlertSeverity.high;
}

String _alertTitle(DashboardAlertSeverity severity) {
  return switch (severity) {
    DashboardAlertSeverity.high => 'Price above target',
    DashboardAlertSeverity.medium => 'Price near target',
    DashboardAlertSeverity.low => 'Target hit',
  };
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final tasks = ref.watch(tasksProvider);
  final poller = ref.watch(pollerProvider);
  return buildDashboardSummary(tasks: tasks, sessionMatches: poller.allMatches);
});

final dashboardAlertsProvider = Provider<List<DashboardAlertItem>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final poller = ref.watch(pollerProvider);
  return buildDashboardAlerts(
    tasks: tasks,
    sessionMatches: poller.allMatches,
    sessionTimestamp: poller.results.isEmpty
        ? null
        : poller.results.last.timestamp,
  );
});

final taskHistoryProvider =
    FutureProvider.family<Map<String, List<(DateTime, int)>>, String>((
      ref,
      taskId,
    ) {
      ref.watch(
        tasksProvider.select((tasks) {
          for (final task in tasks) {
            if (task.id == taskId) return task.lastPolledAt;
          }
          return null;
        }),
      );
      return ref.watch(historyServiceProvider).getTimeSeries(taskId);
    });
