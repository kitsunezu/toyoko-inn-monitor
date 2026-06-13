import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class DashboardPalette {
  final Color background;
  final Color sidebar;
  final Color panel;
  final Color raised;
  final Color border;
  final Color primary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const DashboardPalette({
    required this.background,
    required this.sidebar,
    required this.panel,
    required this.raised,
    required this.border,
    required this.primary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static DashboardPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const DashboardPalette(
        background: AppColors.dashBg,
        sidebar: AppColors.dashSidebar,
        panel: AppColors.dashPanel,
        raised: AppColors.dashPanelRaised,
        border: AppColors.dashBorder,
        primary: AppColors.dashPrimary,
        success: AppColors.dashSuccess,
        warning: AppColors.dashWarning,
        danger: AppColors.dashDanger,
        textPrimary: AppColors.dashTextPrimary,
        textSecondary: AppColors.dashTextSecondary,
        textMuted: AppColors.dashTextMuted,
      );
    }

    return const DashboardPalette(
      background: Color(0xFFF5F7FA),
      sidebar: Color(0xFFFFFFFF),
      panel: Color(0xFFFFFFFF),
      raised: Color(0xFFF0F4F8),
      border: Color(0xFFDDE5EE),
      primary: Color(0xFF2563EB),
      success: Color(0xFF15803D),
      warning: Color(0xFFB7791F),
      danger: Color(0xFFDC2626),
      textPrimary: Color(0xFF111827),
      textSecondary: Color(0xFF4B5563),
      textMuted: Color(0xFF7C8794),
    );
  }
}

class DashboardPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;

  const DashboardPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );

    if (height == null) return panel;
    return SizedBox(height: height, child: panel);
  }
}

class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    subtitle!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const DashboardEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: palette.textMuted),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: palette.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textMuted, fontSize: 12),
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const StatusDot({super.key, required this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

String compactPrice(int? price) {
  if (price == null || price <= 0) return '--';
  final text = price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return 'JPY $text';
}

String compactTime(DateTime? time) {
  if (time == null) return '--:--:--';
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:'
      '${time.second.toString().padLeft(2, '0')}';
}

String compactDate(DateTime? time) {
  if (time == null) return '--';
  return '${time.year.toString().padLeft(4, '0')}-'
      '${time.month.toString().padLeft(2, '0')}-'
      '${time.day.toString().padLeft(2, '0')}';
}
