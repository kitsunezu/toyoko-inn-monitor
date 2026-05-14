import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/hotel_price.dart';
import '../../core/models/search_params.dart';
import '../../providers/poller_provider.dart';
import '../../providers/search_params_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_utils.dart';
import '../../utils/url_utils.dart';

class LivePricesPage extends ConsumerWidget {
  const LivePricesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              '最後更新: ${formatTimestamp(lastResult.timestamp)} '
              '（第 ${lastResult.attempt} 次查詢）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (hotels.isEmpty)
          const Expanded(
            child: Center(child: Text('尚無資料，請先開始監控')),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('飯店')),
                  DataColumn(label: Text('最低價'), numeric: true),
                ],
                rows: sorted
                    .map(
                      (h) => DataRow(
                        onSelectChanged: (_) => _openUrl(context, h, ps),
                        cells: [
                          DataCell(
                            Icon(
                              _iconFor(h),
                              color: h.statusColor,
                              size: 16,
                            ),
                          ),
                          DataCell(
                            Text(h.name, style: const TextStyle(fontSize: 13)),
                          ),
                          DataCell(
                            Text(
                              h.priceStr,
                              style: TextStyle(
                                color: h.available && h.price <= ps.targetPrice
                                    ? AppColors.match
                                    : h.available
                                        ? AppColors.available
                                        : AppColors.noRoom,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
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
          const SnackBar(content: Text('無法開啟瀏覽器')),
        );
      }
    }
  }

  IconData _iconFor(HotelPrice h) {
    if (h.maintenance) return Icons.build_outlined;
    if (h.price <= 0) return Icons.remove;
    if (!h.vacant) return Icons.warning_amber_outlined;
    return Icons.check_circle_outline;
  }
}
