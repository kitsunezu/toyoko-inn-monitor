import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// 主�??��?NavigationRail (桌面) / BottomNavigationBar (?��?)
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _destDefs = [
    (icon: Icons.monitor_heart_outlined, path: '/'),
    (icon: Icons.list_alt_outlined, path: '/tasks'),
    (icon: Icons.date_range_outlined, path: '/scan'),
    (icon: Icons.settings_outlined, path: '/settings'),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _destDefs.length; i++) {
      if (_destDefs[i].path == location) return i;
    }
    return 0;
  }

  List<String> _labels(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [l.navMonitor, l.navTasks, l.navScan, l.navSettings];
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final idx = _selectedIndex(context);
    final labels = _labels(context);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: idx,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) =>
                  context.go(_destDefs[i].path),
              destinations: [
                for (int i = 0; i < _destDefs.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_destDefs[i].icon),
                    label: Text(labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) =>
              context.go(_destDefs[i].path),
          destinations: [
            for (int i = 0; i < _destDefs.length; i++)
              NavigationDestination(
                icon: Icon(_destDefs[i].icon),
                label: labels[i],
              ),
          ],
        ),
      );
    }
  }
}
