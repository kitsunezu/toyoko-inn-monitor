import 'package:flutter/material.dart';

import 'dashboard_style.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final ColorRole colorRole;
  final double? progress;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.colorRole,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    final color = switch (colorRole) {
      ColorRole.primary => palette.primary,
      ColorRole.success => palette.success,
      ColorRole.warning => palette.warning,
      ColorRole.danger => palette.danger,
    };

    return DashboardPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: palette.textSecondary, fontSize: 12),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: progress!.clamp(0.0, 1.0),
                backgroundColor: palette.raised,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum ColorRole { primary, success, warning, danger }
