import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/dashboard_provider.dart';
import 'dashboard_style.dart';

class AlertFeed extends StatelessWidget {
  final List<DashboardAlertItem> alerts;

  const AlertFeed({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);

    return DashboardPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: DashboardSectionTitle(
              title: l.dashboardAlertFeed,
              subtitle: l.dashboardRealTime,
              trailing: Text(
                '${alerts.length}',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: palette.border),
          Expanded(
            child: alerts.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.notifications_none,
                    title: l.dashboardNoAlerts,
                    message: l.dashboardNoAlertsMessage,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: alerts.take(8).length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: palette.border),
                    itemBuilder: (context, index) {
                      return _AlertRow(alert: alerts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final DashboardAlertItem alert;

  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final color = switch (alert.severity) {
      DashboardAlertSeverity.high => palette.danger,
      DashboardAlertSeverity.medium => palette.warning,
      DashboardAlertSeverity.low => palette.success,
    };
    final targetText = alert.targetPrice == null
        ? ''
        : l.dashboardTargetSuffix(compactPrice(alert.targetPrice));
    final taskName = alert.id.startsWith('__main__')
        ? l.dashboardLiveMonitor
        : alert.taskName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              compactTime(alert.timestamp),
              style: TextStyle(color: palette.textMuted, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: StatusDot(color: color, size: 8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _titleFor(alert.severity, l),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      compactPrice(alert.price),
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${alert.hotelName}$targetText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
                Text(
                  taskName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _titleFor(DashboardAlertSeverity severity, AppLocalizations l) {
    return switch (severity) {
      DashboardAlertSeverity.high => l.dashboardPriceAboveTarget,
      DashboardAlertSeverity.medium => l.dashboardPriceNearTarget,
      DashboardAlertSeverity.low => l.dashboardTargetHit,
    };
  }
}
