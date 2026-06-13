import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/models/poll_result.dart';
import '../../data/locations.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_utils.dart';

class PriceChart extends StatelessWidget {
  final List<PollResult> results;
  final int? targetPrice;

  const PriceChart({
    super.key,
    required this.results,
    required this.targetPrice,
  });

  @override
  Widget build(BuildContext context) {
    // 只取最近 40 筆，由左至右累積
    final displayResults = results.length > 40
        ? results.sublist(results.length - 40)
        : results;
    final n = displayResults.length;

    // 收集所有飯店代碼
    final allCodes = <String>{};
    for (final r in displayResults) {
      for (final h in r.hotels) {
        if (h.price > 0) allCodes.add(h.code);
      }
    }

    if (allCodes.isEmpty) {
      return const Center(child: Text('尚無有效報價'));
    }

    final colors = _chartColors();
    final codeList = allCodes.take(15).toList();

    // 建立每條折線的資料
    final lineBarsData = <LineChartBarData>[];
    for (int ci = 0; ci < codeList.length; ci++) {
      final code = codeList[ci];
      final spots = <FlSpot>[];
      for (int ri = 0; ri < n; ri++) {
        final r = displayResults[ri];
        final hotel = r.hotels.where((h) => h.code == code).firstOrNull;
        if (hotel != null && hotel.price > 0) {
          spots.add(FlSpot(ri.toDouble(), hotel.price.toDouble()));
        }
      }
      if (spots.isEmpty) continue;

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colors[ci % colors.length],
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    // Time labels
    final timeLabels = displayResults.asMap().map(
      (i, r) => MapEntry(i, formatTime(r.timestamp)),
    );

    final maxY = displayResults
        .expand((r) => r.hotels.map((h) => h.price))
        .where((p) => p > 0)
        .fold<double>(0, (a, b) => b.toDouble() > a ? b.toDouble() : a);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 39, // 固定 40 格，資料從左累積
        extraLinesData: targetPrice == null
            ? const ExtraLinesData()
            : ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: targetPrice!.toDouble(),
                    color: AppColors.match.withValues(alpha: 0.7),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (_) => '目標 ¥$targetPrice',
                      style: const TextStyle(
                        color: AppColors.match,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
        gridData: FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.textMuted.withValues(alpha: 0.3),
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (v, meta) => Text(
                '¥${(v / 1000).toStringAsFixed(0)}k',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, meta) {
                if (v != v.roundToDouble()) return const SizedBox();
                final idx = v.round();
                if (idx < 0 || idx >= n) return const SizedBox();
                // 每 8 次顯示一個標籤，最後一筆也顯示
                if (idx % 8 != 0 && idx != n - 1) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    timeLabels[idx] ?? '',
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: lineBarsData,
        minY: 0,
        maxY: maxY * 1.1,
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            maxContentWidth: 200,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final ci = spot.barIndex;
                if (ci >= codeList.length) return null;
                final code = codeList[ci];
                final name = kHotelNames[code] ?? code;
                return LineTooltipItem(
                  '¥${spot.y.toInt()}  $name',
                  TextStyle(
                    color: colors[ci % colors.length],
                    fontSize: 11,
                    height: 1.6,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  static List<Color> _chartColors() => [
    AppColors.brand,
    AppColors.brandRed,
    AppColors.available,
    AppColors.warning,
    AppColors.maintenance,
    const Color(0xFFA85A24),
    const Color(0xFF7A8C42),
    AppColors.error,
    const Color(0xFF4F6F8F),
    AppColors.noRoom,
  ];
}
