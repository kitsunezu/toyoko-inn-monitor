import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/models/monitor_task.dart';
import '../../core/models/poll_result.dart';
import '../../core/services/date_scan_service.dart';
import '../../data/locations.dart';
import '../../l10n/app_localizations.dart';
import 'dashboard_style.dart';

class DashboardPriceTrendChart extends StatelessWidget {
  final List<PollResult> results;
  final int? targetPrice;

  const DashboardPriceTrendChart({
    super.key,
    required this.results,
    required this.targetPrice,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final displayResults = results.length > 40
        ? results.sublist(results.length - 40)
        : results;
    final codes = <String>{};
    for (final result in displayResults) {
      for (final hotel in result.hotels) {
        if (hotel.price > 0) codes.add(hotel.code);
      }
    }

    return DashboardPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionTitle(
            title: l.dashboardPriceTrend,
            subtitle: targetPrice == null
                ? l.dashboardLiveMonitor
                : l.dashboardTargetPrice(compactPrice(targetPrice)),
            trailing: _Legend(palette: palette),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: codes.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.show_chart,
                    title: l.dashboardNoTrendData,
                    message: l.dashboardNoTrendDataMessage,
                  )
                : LineChart(
                    _chartData(context, displayResults, codes.toList()),
                  ),
          ),
        ],
      ),
    );
  }

  LineChartData _chartData(
    BuildContext context,
    List<PollResult> displayResults,
    List<String> codes,
  ) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final chartColors = _seriesColors(palette);
    final series = <LineChartBarData>[];
    final visibleCodes = codes.take(8).toList();

    for (var codeIndex = 0; codeIndex < visibleCodes.length; codeIndex++) {
      final code = visibleCodes[codeIndex];
      final spots = <FlSpot>[];
      for (var index = 0; index < displayResults.length; index++) {
        final result = displayResults[index];
        final matches = result.hotels.where((hotel) => hotel.code == code);
        if (matches.isEmpty) continue;
        final hotel = matches.first;
        if (hotel.price > 0) {
          spots.add(FlSpot(index.toDouble(), hotel.price.toDouble()));
        }
      }
      if (spots.isEmpty) continue;
      series.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: chartColors[codeIndex % chartColors.length],
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: codeIndex == 0,
            color: chartColors[codeIndex % chartColors.length].withValues(
              alpha: 0.09,
            ),
          ),
        ),
      );
    }

    final prices = displayResults
        .expand((result) => result.hotels.map((hotel) => hotel.price))
        .where((price) => price > 0)
        .toList();
    final maxPrice = prices.isEmpty
        ? 10000.0
        : prices.reduce((a, b) => a > b ? a : b).toDouble();
    final minPrice = prices.isEmpty
        ? 0.0
        : prices.reduce((a, b) => a < b ? a : b).toDouble();
    final paddedMin = (minPrice * 0.88).clamp(0.0, double.infinity);
    final paddedMax = maxPrice * 1.12;

    return LineChartData(
      minX: 0,
      maxX: (displayResults.length - 1).clamp(0, 40).toDouble(),
      minY: paddedMin,
      maxY: paddedMax <= paddedMin ? paddedMin + 1000 : paddedMax,
      lineBarsData: series,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: palette.border, strokeWidth: 1, dashArray: [4, 6]),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 54,
            getTitlesWidget: (value, meta) => Text(
              'JPY ${(value / 1000).toStringAsFixed(0)}k',
              style: TextStyle(color: palette.textMuted, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.round();
              if (index < 0 || index >= displayResults.length) {
                return const SizedBox.shrink();
              }
              final step = displayResults.length > 10 ? 5 : 2;
              if (index != displayResults.length - 1 && index % step != 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  compactTime(displayResults[index].timestamp),
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
                  y: targetPrice!.toDouble(),
                  color: palette.warning,
                  strokeWidth: 1.5,
                  dashArray: [8, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
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
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final code = visibleCodes[spot.barIndex];
              return LineTooltipItem(
                '${kHotelNames[code] ?? code}\n${compactPrice(spot.y.toInt())}',
                TextStyle(
                  color: chartColors[spot.barIndex % chartColors.length],
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  static List<Color> _seriesColors(DashboardPalette palette) => [
    palette.primary,
    palette.success,
    palette.warning,
    const Color(0xFF7C5CFF),
    const Color(0xFF18C3B7),
    const Color(0xFFFF8B4A),
    const Color(0xFF9BDB69),
    palette.danger,
  ];
}

class DateRangePricePanel extends StatelessWidget {
  final List<DateScanResult> results;

  const DateRangePricePanel({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final valid = results.where((result) => result.lowestPrice > 0).toList();
    final minPrice = valid.isEmpty
        ? 0
        : valid
              .map((result) => result.lowestPrice)
              .reduce((a, b) => a < b ? a : b);
    final maxPrice = valid.isEmpty
        ? 0
        : valid
              .map((result) => result.lowestPrice)
              .reduce((a, b) => a > b ? a : b);

    return DashboardPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionTitle(
            title: l.dashboardDateRangePrices,
            subtitle: l.dashboardCheapestCheckinDays,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: results.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: l.dashboardNoScanData,
                    message: l.dashboardNoScanDataMessage,
                  )
                : BarChart(_barData(context, minPrice, maxPrice)),
          ),
          if (results.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _HeatLegend(
                  color: palette.success,
                  label: l.dashboardLowestLegend,
                ),
                const SizedBox(width: 12),
                _HeatLegend(
                  color: palette.warning,
                  label: l.dashboardNearTarget,
                ),
                const SizedBox(width: 12),
                _HeatLegend(color: palette.danger, label: l.dashboardHigh),
              ],
            ),
          ],
        ],
      ),
    );
  }

  BarChartData _barData(BuildContext context, int minPrice, int maxPrice) {
    final palette = DashboardPalette.of(context);
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxPrice <= 0 ? 10000 : maxPrice * 1.15,
      minY: 0,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: palette.border, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (value, meta) => Text(
              '${(value / 1000).toStringAsFixed(0)}k',
              style: TextStyle(color: palette.textMuted, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= results.length) {
                return const SizedBox.shrink();
              }
              final step = results.length > 10 ? 2 : 1;
              if (index % step != 0) return const SizedBox.shrink();
              final parts = results[index].date.split('-');
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  parts.length == 3
                      ? '${parts[1]}/${parts[2]}'
                      : results[index].date,
                  style: TextStyle(color: palette.textMuted, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (var index = 0; index < results.length; index++)
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: results[index].lowestPrice <= 0
                    ? 0
                    : results[index].lowestPrice.toDouble(),
                width: results.length > 18 ? 8 : 14,
                borderRadius: BorderRadius.circular(3),
                color: _barColor(results[index].lowestPrice, minPrice, palette),
              ),
            ],
          ),
      ],
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final result = results[group.x];
            if (result.lowestPrice <= 0) return null;
            return BarTooltipItem(
              '${result.date}\n${compactPrice(result.lowestPrice)}',
              TextStyle(
                color: palette.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ),
    );
  }

  static Color _barColor(int price, int minPrice, DashboardPalette palette) {
    if (price <= 0) return palette.textMuted;
    if (price == minPrice) return palette.success;
    if (minPrice <= 0 || price <= minPrice * 1.12) return palette.warning;
    return palette.danger;
  }
}

class HotelDistributionDonut extends StatelessWidget {
  final List<MonitorTask> tasks;

  const HotelDistributionDonut({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final counts = <String, int>{};
    for (final task in tasks) {
      counts.update(
        task.params.location,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      palette.primary,
      palette.success,
      palette.warning,
      const Color(0xFF7C5CFF),
      palette.danger,
      const Color(0xFF18C3B7),
    ];

    return DashboardPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionTitle(
            title: l.dashboardLocationDistribution,
            subtitle: l.dashboardAllMonitors,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: tasks.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.donut_large,
                    title: l.dashboardNoDistribution,
                    message: l.dashboardNoDistributionMessage,
                  )
                : Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 42,
                            sections: [
                              for (
                                var index = 0;
                                index < entries.length;
                                index++
                              )
                                PieChartSectionData(
                                  value: entries[index].value.toDouble(),
                                  title: '',
                                  radius: 34,
                                  color: colors[index % colors.length],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 145,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (
                              var index = 0;
                              index < entries.take(6).length;
                              index++
                            )
                              _DistributionLegend(
                                label: entries[index].key,
                                value: entries[index].value,
                                color: colors[index % colors.length],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final DashboardPalette palette;

  const _Legend({required this.palette});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeatLegend(color: palette.primary, label: l.dashboardLowestLegend),
        const SizedBox(width: 10),
        _HeatLegend(color: palette.warning, label: l.labelTargetShort),
      ],
    );
  }
}

class _HeatLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _HeatLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: palette.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _DistributionLegend extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _DistributionLegend({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          StatusDot(color: color, size: 8),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textSecondary, fontSize: 11),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
