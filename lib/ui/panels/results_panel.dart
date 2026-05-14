import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/hotel_price.dart';
import '../../core/models/search_params.dart';
import '../../providers/poller_provider.dart';
import '../../providers/search_params_provider.dart';
import '../widgets/price_chart.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_utils.dart';
import '../../utils/url_utils.dart';

class ResultsPanel extends ConsumerWidget {
  const ResultsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.table_chart_outlined), text: l.tabLivePrices),
              Tab(icon: const Icon(Icons.article_outlined), text: l.tabLog),
              Tab(icon: const Icon(Icons.show_chart), text: l.tabPriceHistory),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _PriceTableTab(),
                _LogTab(),
                _ChartTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ?�?� Price Table Tab ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _PriceTableTab extends ConsumerWidget {
  const _PriceTableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final hotels = ref.watch(pollerProvider.select((s) => s.latestHotels));
    final ps = ref.watch(searchParamsProvider);
    final lastResult = ref.watch(
      pollerProvider.select(
        (s) => s.results.isNotEmpty ? s.results.last : null,
      ),
    );

    final sorted = [...hotels]..sort((a, b) {
      if (a.available && !b.available) return -1;
      if (!a.available && b.available) return 1;
      if (a.price <= 0) return 1;
      if (b.price <= 0) return -1;
      return a.price.compareTo(b.price);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lastResult != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              l.lastUpdateLabel(
                formatTimestamp(lastResult.timestamp),
                lastResult.attempt,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (hotels.isEmpty)
          Expanded(child: Center(child: Text(l.noDataYet)))
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.columnHotel,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      Text(
                        l.columnLowestPrice,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final h = sorted[i];
                      return InkWell(
                        mouseCursor: SystemMouseCursors.click,
                        onTap: () => _openUrl(context, h, ps),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  h.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: h.available
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                  ),
                                ),
                              ),
                              Text(
                                h.priceStr,
                                style: TextStyle(
                                  color: h.available &&
                                          h.price <= ps.targetPrice
                                      ? AppColors.match
                                      : h.available
                                          ? AppColors.available
                                          : AppColors.noRoom,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _openUrl(BuildContext context, HotelPrice h, SearchParams ps) async {
    final url = buildBookingUrl(
      hotelCode: h.code,
      checkin: ps.checkin,
      checkout: ps.checkout,
      rooms: ps.numRooms,
      people: ps.numPeople,
      smokingType: ps.smokingType,
    );
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cantOpenBrowser),
          ),
        );
      }
    }
  }

}

// ?�?� Log Tab ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _LogTab extends ConsumerWidget {
  const _LogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(pollerProvider.select((s) => s.logs));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: logs.length,
      itemBuilder: (context, i) {
        final line = logs[i];
        return _LogLine(text: line);
      },
    );
  }
}

class _LogLine extends StatelessWidget {
  final String text;
  const _LogLine({required this.text});

  static Color _colorFor(String t) {
    if (t.contains('⭐')) return AppColors.match;
    if (t.contains('✓')) return AppColors.available;
    if (t.contains('⚠')) return AppColors.warning;
    if (t.contains('❌')) return AppColors.error;
    if (t.contains('🔧')) return AppColors.maintenance;
    if (t.contains('─')) return AppColors.noRoom;
    if (t.contains('[') && t.contains(':')) return AppColors.noRoom;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5,
        height: 1.4,
        color: _colorFor(text),
      ),
    );
  }
}

// ?�?� Chart Tab ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _ChartTab extends ConsumerWidget {
  const _ChartTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(pollerProvider.select((s) => s.results));
    final ps = ref.watch(searchParamsProvider);

    if (results.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noChartData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: PriceChart(
        results: results,
        targetPrice: ps.targetPrice,
      ),
    );
  }
}
