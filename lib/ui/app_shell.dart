import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/monitor_task.dart';
import '../l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';
import '../providers/poller_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/update_provider.dart';
import 'dashboard/dashboard_style.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _destinations = [
    _ShellDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      path: '/',
    ),
    _ShellDestination(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      path: '/scan',
    ),
    _ShellDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      path: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = DashboardPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final collapsed = width < 1000;

    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          const _DashboardHeader(),
          Expanded(
            child: Row(
              children: [
                _DashboardSidebar(
                  destinations: _destinations,
                  collapsed: collapsed,
                ),
                VerticalDivider(width: 1, thickness: 1, color: palette.border),
                Expanded(child: child),
              ],
            ),
          ),
          const _DashboardStatusBar(),
        ],
      ),
    );
  }
}

class _PollTiming {
  final bool running;
  final double countdown;
  final int nextPollSeconds;

  const _PollTiming({
    required this.running,
    required this.countdown,
    required this.nextPollSeconds,
  });

  factory _PollTiming.from(List<MonitorTask> tasks, PollerState poller) {
    final activeTasks = tasks.where(_isActiveTask);
    MonitorTask? nextTask;
    var nextRemaining = double.infinity;

    for (final task in activeTasks) {
      final total = task.tickTotal > 0
          ? task.tickTotal
          : task.params.intervalSec.toDouble();
      final elapsed = _clampDouble(task.tickElapsed, 0, total);
      final remaining = total - elapsed;
      if (remaining < nextRemaining) {
        nextTask = task;
        nextRemaining = remaining;
      }
    }

    if (nextTask != null) {
      final total = nextTask.tickTotal > 0
          ? nextTask.tickTotal
          : nextTask.params.intervalSec.toDouble();
      return _PollTiming._running(nextTask.tickElapsed, total);
    }

    if (poller.running) {
      return _PollTiming._running(poller.tickElapsed, poller.tickTotal);
    }

    return const _PollTiming(running: false, countdown: 0, nextPollSeconds: 0);
  }

  factory _PollTiming._running(double elapsed, double total) {
    final safeTotal = total <= 0 ? 1.0 : total;
    final safeElapsed = _clampDouble(elapsed, 0, safeTotal);
    final remaining = safeTotal - safeElapsed;
    final seconds = remaining.ceil();

    return _PollTiming(
      running: true,
      countdown: 1 - (safeElapsed / safeTotal),
      nextPollSeconds: seconds < 0
          ? 0
          : seconds > 999
          ? 999
          : seconds,
    );
  }

  static bool _isActiveTask(MonitorTask task) {
    return task.status == TaskStatus.running ||
        task.status == TaskStatus.matched;
  }

  static double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final summary = ref.watch(dashboardSummaryProvider);
    final poller = ref.watch(pollerProvider);
    final tasks = ref.watch(tasksProvider);
    final pollTiming = _PollTiming.from(tasks, poller);
    final alertsEnabled = ref.watch(desktopNotificationProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: palette.sidebar,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(Icons.hotel_outlined, color: palette.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Text(
            l.appTitle,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          _CountdownBadge(
            value: pollTiming.countdown,
            seconds: pollTiming.nextPollSeconds,
          ),
          const SizedBox(width: 10),
          _HeaderChip(
            icon: Icons.circle,
            iconColor: pollTiming.running ? palette.success : palette.textMuted,
            label: l.dashboardPollingEvery(summary.pollIntervalSec),
          ),
          const SizedBox(width: 18),
          _HeaderSwitch(
            label: l.dashboardGlobalAlerts,
            value: alertsEnabled,
            onChanged: (value) {
              ref.read(settingsServiceProvider).setDesktopNotification(value);
              ref.read(desktopNotificationProvider.notifier).state = value;
            },
          ),
          _HeaderIconButton(
            tooltip: l.dashboardToggleTheme,
            icon: themeMode == 'light'
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            label: themeMode == 'light'
                ? l.dashboardThemeLightShort
                : l.dashboardThemeDarkShort,
            onPressed: () {
              final next = themeMode == 'light' ? 'dark' : 'light';
              ref.read(settingsServiceProvider).setThemeMode(next);
              ref.read(themeModeProvider.notifier).state = next;
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardSidebar extends ConsumerWidget {
  final List<_ShellDestination> destinations;
  final bool collapsed;

  const _DashboardSidebar({
    required this.destinations,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final versionLabel = ref
        .watch(appVersionProvider)
        .maybeWhen(data: (version) => 'v$version', orElse: () => null);

    return Container(
      width: collapsed ? 72 : 220,
      color: palette.sidebar,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final destination in destinations)
            _SidebarItem(
              destination: destination,
              label: destination.label(l),
              selected:
                  destination.path == location ||
                  (destination.path == '/' && location == '/tasks'),
              collapsed: collapsed,
              badge: _badgeFor(destination.path),
              onTap: () => context.go(destination.path),
            ),
          const SizedBox(height: 18),
          Divider(color: palette.border),
          const Spacer(),
          if (!collapsed && versionLabel != null)
            Text(
              versionLabel,
              style: TextStyle(color: palette.textMuted, fontSize: 12),
            ),
        ],
      ),
    );
  }

  int? _badgeFor(String path) {
    return switch (path) {
      '/' => null,
      '/scan' => null,
      '/settings' => null,
      _ => null,
    };
  }
}

class _DashboardStatusBar extends ConsumerWidget {
  const _DashboardStatusBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final summary = ref.watch(dashboardSummaryProvider);
    final poller = ref.watch(pollerProvider);

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: palette.sidebar,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatusText(
            label: l.dashboardLastUpdated,
            value:
                '${compactDate(summary.lastUpdated)} ${compactTime(summary.lastUpdated)}',
          ),
          const Spacer(),
          _StatusText(
            label: l.dashboardDatabase,
            value: l.dashboardConnected,
            valueColor: palette.success,
          ),
          const SizedBox(width: 24),
          StatusDot(
            color: poller.running || summary.runningTasks > 0
                ? palette.success
                : palette.textMuted,
            size: 7,
          ),
          const SizedBox(width: 6),
          _StatusText(
            label: l.dashboardPolling,
            value: poller.running || summary.runningTasks > 0
                ? l.dashboardRunning
                : l.dashboardIdle,
          ),
        ],
      ),
    );
  }
}

class _ShellDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const _ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });

  String label(AppLocalizations l) {
    return switch (path) {
      '/' => l.dashboardNavActiveMonitors,
      '/scan' => l.pageScanTitle,
      '/settings' => l.pageSettingsTitle,
      _ => path,
    };
  }
}

class _SidebarItem extends StatelessWidget {
  final _ShellDestination destination;
  final String label;
  final bool selected;
  final bool collapsed;
  final int? badge;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.destination,
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    final color = selected ? palette.primary : palette.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Tooltip(
        message: collapsed ? label : '',
        child: Material(
          color: selected
              ? palette.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              height: 42,
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (!collapsed) const SizedBox(width: 12),
                  Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    color: color,
                    size: 20,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (badge != null)
                      _CountBadge(
                        value: badge!,
                        color: selected ? palette.primary : palette.textMuted,
                      ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final double value;
  final int seconds;

  const _CountdownBadge({required this.value, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 3,
            backgroundColor: palette.raised,
            color: palette.primary,
          ),
          Text(
            '${seconds}s',
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

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _HeaderChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.raised,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 8, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: palette.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HeaderSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _HeaderSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: palette.textSecondary, fontSize: 12),
        ),
        Transform.scale(
          scale: 0.78,
          child: Switch(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: tooltip,
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: palette.textSecondary,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int value;
  final Color color;

  const _CountBadge({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$value',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusText({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return RichText(
      text: TextSpan(
        style: TextStyle(color: palette.textMuted, fontSize: 12),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor ?? palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
