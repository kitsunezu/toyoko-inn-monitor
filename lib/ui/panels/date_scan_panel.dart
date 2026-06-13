import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/date_scan_service.dart';
import '../../data/locations.dart';
import '../../providers/date_scan_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_utils.dart';
import '../../utils/url_utils.dart';

class DateScanPanel extends ConsumerStatefulWidget {
  const DateScanPanel({super.key});

  @override
  ConsumerState<DateScanPanel> createState() => _DateScanPanelState();
}

class _DateScanPanelState extends ConsumerState<DateScanPanel> {
  String _city = kLocations.keys.first;
  late String _startDate;
  late String _endDate;

  @override
  void initState() {
    super.initState();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _startDate = formatDate(tomorrow);
    _endDate = formatDate(tomorrow.add(const Duration(days: 13)));
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(dateScanProvider);
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.pageScanTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ?�?� Config card ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City dropdown
                    _FieldLabel(l.labelCity),
                    DropdownButtonFormField<String>(
                      value: _city,
                      isExpanded: true,
                      decoration: _inputDec(),
                      items: kLocations.keys
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: scanState.scanning
                          ? null
                          : (v) {
                              if (v != null) setState(() => _city = v);
                            },
                    ),
                    const SizedBox(height: 12),

                    // Date range row
                    Row(
                      children: [
                        // Start date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(l.labelStartDate),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: scanState.scanning
                                    ? null
                                    : () => _pickStart(context),
                                child: InputDecorator(
                                  decoration: _inputDec(),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: cs.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_startDate),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18, color: cs.outline),
                        const SizedBox(width: 8),
                        // End date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(l.labelEndDate),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: scanState.scanning
                                    ? null
                                    : () => _pickEnd(context),
                                child: InputDecorator(
                                  decoration: _inputDec(),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: cs.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_endDate),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.search),
                          label: Text(
                            scanState.scanning ? l.btnScanning : l.btnStartScan,
                          ),
                          onPressed: scanState.scanning ? null : _startScan,
                        ),
                        if (scanState.results.isNotEmpty &&
                            !scanState.scanning) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.clear),
                            label: Text(l.btnClear),
                            onPressed: () =>
                                ref.read(dateScanProvider.notifier).clear(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ?�?� Progress bar ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
            if (scanState.scanning) ...[
              LinearProgressIndicator(
                value: _scanProgress(scanState.results),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '${scanState.results.length} / ${_totalDays()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],

            // ?�?� Results ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
            if (scanState.results.isNotEmpty)
              Expanded(
                child: _ScanResults(results: scanState.results, city: _city),
              )
            else if (!scanState.scanning)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 64,
                        color: cs.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.scanHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.outline),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _totalDays() {
    try {
      final s = DateTime.parse(_startDate);
      final e = DateTime.parse(_endDate);
      return e.difference(s).inDays + 1;
    } catch (_) {
      return 1;
    }
  }

  double _scanProgress(List<DateScanResult> results) {
    final total = _totalDays();
    if (total <= 0 || results.isEmpty) return 0;
    return results.length / total;
  }

  Future<void> _pickStart(BuildContext context) async {
    DateTime initial;
    try {
      initial = DateTime.parse(_startDate);
    } catch (_) {
      initial = DateTime.now().add(const Duration(days: 1));
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = formatDate(picked);
        try {
          final e = DateTime.parse(_endDate);
          if (e.isBefore(picked)) {
            _endDate = formatDate(picked.add(const Duration(days: 13)));
          }
        } catch (_) {}
      });
    }
  }

  Future<void> _pickEnd(BuildContext context) async {
    DateTime startDt;
    try {
      startDt = DateTime.parse(_startDate);
    } catch (_) {
      startDt = DateTime.now().add(const Duration(days: 1));
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: startDt.add(const Duration(days: 13)),
      firstDate: startDt.add(const Duration(days: 1)),
      lastDate: startDt.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _endDate = formatDate(picked));
    }
  }

  void _startScan() {
    final cityHotels = kLocations[_city] ?? [];
    if (cityHotels.isEmpty) return;
    final names = Map.fromEntries(
      cityHotels.map((c) => MapEntry(c, kHotelNames[c] ?? c)),
    );
    ref
        .read(dateScanProvider.notifier)
        .scan(
          startDate: _startDate,
          endDate: _endDate,
          hotelCodes: cityHotels,
          hotelNames: names,
        );
  }
}

// ?�?� Results area ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _ScanResults extends StatelessWidget {
  final List<DateScanResult> results;
  final String city;

  const _ScanResults({required this.results, required this.city});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final valid = results.where((r) => r.lowestPrice > 0).toList();

    if (valid.isEmpty) {
      return Center(child: Text(l.noValidPrices));
    }

    final maxPrice = valid
        .map((r) => r.lowestPrice)
        .reduce((a, b) => a > b ? a : b);
    final minPrice = valid
        .map((r) => r.lowestPrice)
        .reduce((a, b) => a < b ? a : b);
    final cheapest = valid.firstWhere((r) => r.lowestPrice == minPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsRow(
          minPrice: minPrice,
          maxPrice: maxPrice,
          cheapestDate: cheapest.date,
          cheapestHotel: cheapest.hotelName,
          count: results.length,
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 3,
          child: _ScanChart(results: results, minPrice: minPrice),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: _PriceList(results: results, minPrice: minPrice),
        ),
      ],
    );
  }
}

// ?�?� Stats summary row ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _StatsRow extends StatelessWidget {
  final int minPrice;
  final int maxPrice;
  final String cheapestDate;
  final String? cheapestHotel;
  final int count;

  const _StatsRow({
    required this.minPrice,
    required this.maxPrice,
    required this.cheapestDate,
    required this.cheapestHotel,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _StatChip(
              icon: Icons.arrow_downward,
              label: l.scanMinLabel,
              value: formatPrice(minPrice),
              color: AppColors.available,
            ),
            const SizedBox(width: 16),
            _StatChip(
              icon: Icons.arrow_upward,
              label: l.scanMaxLabel,
              value: formatPrice(maxPrice),
              color: cs.outline,
            ),
            const Spacer(),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cheapestDate,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.match,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (cheapestHotel != null)
                    Text(
                      cheapestHotel!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  Text(
                    l.scanDaysCount(count),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ?�?� Bar chart ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _ScanChart extends StatelessWidget {
  final List<DateScanResult> results;
  final int minPrice;
  const _ScanChart({required this.results, required this.minPrice});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: results.asMap().entries.map((e) {
          final idx = e.key;
          final r = e.value;
          final price = r.lowestPrice <= 0 ? 0.0 : r.lowestPrice.toDouble();
          final isMin = r.lowestPrice == minPrice && r.lowestPrice > 0;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: price,
                color: r.lowestPrice <= 0
                    ? AppColors.noRoom
                    : isMin
                    ? AppColors.match
                    : AppColors.primary,
                width: results.length > 20 ? 8 : 14,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= results.length) {
                  return const SizedBox();
                }
                final step = results.length > 14
                    ? (results.length ~/ 7 + 1)
                    : 1;
                if (idx % step != 0) return const SizedBox();
                final parts = results[idx].date.split('-');
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${parts[1]}/${parts[2]}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 55,
              getTitlesWidget: (v, meta) => Text(
                '¥${(v / 1000).toStringAsFixed(0)}k',
                style: const TextStyle(fontSize: 10),
              ),
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
        gridData: const FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: false,
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final r = results[group.x];
              if (r.lowestPrice <= 0) return null;
              return BarTooltipItem(
                '${r.date}\n${formatPrice(r.lowestPrice)}',
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ?�?� Scrollable price list ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _PriceList extends StatelessWidget {
  final List<DateScanResult> results;
  final int minPrice;
  const _PriceList({required this.results, required this.minPrice});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final r = results[i];
        final isMin = r.lowestPrice == minPrice && r.lowestPrice > 0;
        final color = r.lowestPrice <= 0
            ? AppColors.noRoom
            : isMin
            ? AppColors.match
            : AppColors.available;
        final bgColor = isMin
            ? cs.primaryContainer.withValues(alpha: 0.15)
            : null;
        final canOpen = r.hotelCode != null && r.lowestPrice > 0;
        return Material(
          color: bgColor ?? Colors.transparent,
          child: InkWell(
            mouseCursor: canOpen ? SystemMouseCursors.click : MouseCursor.defer,
            onTap: canOpen ? () => _openUrl(r) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          r.date,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isMin
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (r.hotelName != null)
                          Text(
                            r.hotelName!,
                            style: const TextStyle(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    r.lowestPrice <= 0 ? '—' : formatPrice(r.lowestPrice),
                    style: TextStyle(
                      color: color,
                      fontWeight: isMin ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openUrl(DateScanResult r) async {
    final checkout = formatDate(
      DateTime.parse(r.date).add(const Duration(days: 1)),
    );
    final url = buildBookingUrl(
      hotelCode: r.hotelCode!,
      checkin: r.date,
      checkout: checkout,
    );
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

// ?�?� Helpers ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium),
  );
}

InputDecoration _inputDec() => const InputDecoration(
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
);
