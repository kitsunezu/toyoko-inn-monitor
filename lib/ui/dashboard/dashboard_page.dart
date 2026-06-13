import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/monitor_task.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/tasks_provider.dart';
import 'alert_feed.dart';
import 'dashboard_style.dart';
import 'monitor_task_table.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = DashboardPalette.of(context);
    final tasks = ref.watch(tasksProvider);
    final focusedTask = _focusedTask(tasks);
    final alerts = ref.watch(dashboardAlertsProvider);
    final focusedAlerts = focusedTask == null
        ? const <DashboardAlertItem>[]
        : alerts
              .where((alert) => alert.id.startsWith('${focusedTask.id}-'))
              .toList();

    return ColoredBox(
      color: palette.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1080;

          final content = compact
              ? SingleChildScrollView(
                  child: _CompactFocusLayout(
                    task: focusedTask,
                    alerts: focusedAlerts,
                  ),
                )
              : _WideFocusLayout(task: focusedTask, alerts: focusedAlerts);

          return Padding(padding: const EdgeInsets.all(16), child: content);
        },
      ),
    );
  }

  static MonitorTask? _focusedTask(List<MonitorTask> tasks) {
    if (tasks.isEmpty) return null;
    final ranked = [...tasks];
    ranked.sort((a, b) {
      final statusCompare = _statusRank(b).compareTo(_statusRank(a));
      if (statusCompare != 0) return statusCompare;
      final aTime = a.lastPolledAt ?? a.createdAt;
      final bTime = b.lastPolledAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return ranked.first;
  }

  static int _statusRank(MonitorTask task) {
    return switch (task.status) {
      TaskStatus.matched => 4,
      TaskStatus.running => 3,
      TaskStatus.idle => 2,
      TaskStatus.stopped => 1,
      TaskStatus.error => 0,
    };
  }
}

class _WideFocusLayout extends StatelessWidget {
  final MonitorTask? task;
  final List<DashboardAlertItem> alerts;

  const _WideFocusLayout({required this.task, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 7, child: ActiveMonitorPanel(task: task)),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(flex: 4, child: _FocusedHistoryPanel(task: task)),
              const SizedBox(height: 12),
              Expanded(flex: 3, child: AlertFeed(alerts: alerts)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactFocusLayout extends StatelessWidget {
  final MonitorTask? task;
  final List<DashboardAlertItem> alerts;

  const _CompactFocusLayout({required this.task, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActiveMonitorPanel(task: task),
        const SizedBox(height: 12),
        SizedBox(height: 360, child: _FocusedHistoryPanel(task: task)),
        const SizedBox(height: 12),
        SizedBox(height: 320, child: AlertFeed(alerts: alerts)),
      ],
    );
  }
}

class _FocusedHistoryPanel extends ConsumerWidget {
  final MonitorTask? task;

  const _FocusedHistoryPanel({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final currentTask = task;

    if (currentTask == null) {
      return DashboardPanel(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionTitle(
              title: l.dashboardPriceTrend,
              subtitle: l.dashboardNoTaskSelected,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DashboardEmptyState(
                icon: Icons.timeline,
                title: l.dashboardNoTaskSelected,
                message: l.dashboardNoTaskSelectedMessage,
              ),
            ),
          ],
        ),
      );
    }

    final history = ref.watch(taskHistoryProvider(currentTask.id));

    return history.when(
      data: (series) =>
          _FocusedHistoryContent(task: currentTask, series: series),
      loading: () => DashboardPanel(
        child: Center(child: CircularProgressIndicator(color: palette.primary)),
      ),
      error: (error, stackTrace) => DashboardPanel(
        child: DashboardEmptyState(
          icon: Icons.error_outline,
          title: l.dashboardCouldNotLoadHistory,
          message: error.toString(),
        ),
      ),
    );
  }
}

class _FocusedHistoryContent extends StatelessWidget {
  final MonitorTask task;
  final Map<String, List<(DateTime, int)>> series;

  const _FocusedHistoryContent({required this.task, required this.series});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final populated = series.entries
        .where((entry) => entry.value.isNotEmpty)
        .take(6)
        .toList();

    return DashboardPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionTitle(
            title: l.dashboardPriceTrend,
            subtitle: task.params.targetPrice == null
                ? l.dashboardLiveMonitor
                : l.dashboardTargetPrice(compactPrice(task.params.targetPrice)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: populated.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.show_chart,
                    title: l.dashboardNoStoredPrices,
                    message: l.dashboardNoStoredPricesMessage,
                  )
                : LineChart(
                    _historyChartData(
                      context: context,
                      series: populated,
                      targetPrice: task.params.targetPrice,
                    ),
                  ),
          ),
          if (populated.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (var index = 0; index < populated.length; index++)
                  _HistoryLegend(
                    code: populated[index].key,
                    count: populated[index].value.length,
                    color: _colors(palette)[index % _colors(palette).length],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  LineChartData _historyChartData({
    required BuildContext context,
    required List<MapEntry<String, List<(DateTime, int)>>> series,
    required int? targetPrice,
  }) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final colors = _colors(palette);
    final prices = [
      ?targetPrice,
      ...series.expand((entry) => entry.value.map((point) => point.$2)),
    ].where((price) => price > 0).toList();
    final maxPrice = prices.reduce((a, b) => a > b ? a : b).toDouble();
    final minPrice = prices.reduce((a, b) => a < b ? a : b).toDouble();
    final maxPoints = series
        .map((entry) => entry.value.length)
        .reduce((a, b) => a > b ? a : b);

    return LineChartData(
      minX: 0,
      maxX: maxPoints <= 1 ? 1 : (maxPoints - 1).toDouble(),
      minY: (minPrice * 0.88).clamp(0.0, double.infinity),
      maxY: maxPrice <= minPrice ? minPrice + 1000 : maxPrice * 1.12,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: palette.border, strokeWidth: 1, dashArray: [5, 6]),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 56,
            getTitlesWidget: (value, meta) => Text(
              'JPY ${(value / 1000).toStringAsFixed(0)}k',
              style: TextStyle(color: palette.textMuted, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final index = value.round();
              if (index < 0 || index >= maxPoints) {
                return const SizedBox.shrink();
              }
              if (maxPoints > 8 && index % 3 != 0 && index != maxPoints - 1) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(color: palette.textMuted, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      extraLinesData: targetPrice == null
          ? const ExtraLinesData()
          : ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: targetPrice.toDouble(),
                  color: palette.warning,
                  dashArray: [8, 5],
                  strokeWidth: 1.5,
                  label: HorizontalLineLabel(
                    show: true,
                    labelResolver: (_) => l.labelTargetShort,
                    style: TextStyle(
                      color: palette.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
      lineTouchData: LineTouchData(handleBuiltInTouches: true),
      lineBarsData: [
        for (var seriesIndex = 0; seriesIndex < series.length; seriesIndex++)
          LineChartBarData(
            spots: [
              for (
                var pointIndex = 0;
                pointIndex < series[seriesIndex].value.length;
                pointIndex++
              )
                FlSpot(
                  pointIndex.toDouble(),
                  series[seriesIndex].value[pointIndex].$2.toDouble(),
                ),
            ],
            isCurved: true,
            color: colors[seriesIndex % colors.length],
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: seriesIndex == 0,
              color: colors[seriesIndex % colors.length].withValues(
                alpha: 0.08,
              ),
            ),
          ),
      ],
    );
  }

  static List<Color> _colors(DashboardPalette palette) => [
    palette.primary,
    palette.danger,
    palette.success,
    palette.warning,
    const Color(0xFF2F80A8),
    const Color(0xFFA85A24),
    const Color(0xFF7A8C42),
  ];
}

class _HistoryLegend extends StatelessWidget {
  final String code;
  final int count;
  final Color color;

  const _HistoryLegend({
    required this.code,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusDot(color: color),
        const SizedBox(width: 6),
        Text(
          l.dashboardHistoryPoints(code, count),
          style: TextStyle(color: palette.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
