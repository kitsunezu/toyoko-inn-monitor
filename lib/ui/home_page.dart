import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'panels/search_panel.dart';
import 'panels/hotel_panel.dart';
import 'panels/control_panel.dart';
import 'panels/results_panel.dart';

/// 主監?��?????左�? (?��?+飯�?+?�制) + ?��? (結�?)
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column ??fixed 370px wide
          SizedBox(
            width: 370,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                SearchPanel(),
                SizedBox(height: 8),
                HotelPanel(),
                SizedBox(height: 8),
                ControlPanel(),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right column ??flex
          const Expanded(child: ResultsPanel()),
        ],
      );
    } else {
      // Mobile: TabBar layout
      final l = AppLocalizations.of(context)!;
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: l.tabSearch),
                Tab(text: l.tabResults),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: const [
                      SearchPanel(),
                      SizedBox(height: 8),
                      HotelPanel(),
                      SizedBox(height: 8),
                      ControlPanel(),
                    ],
                  ),
                  const ResultsPanel(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
