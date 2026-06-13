import 'dart:math' as math;

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
        background: AppColors.dashDarkBg,
        sidebar: AppColors.dashDarkSidebar,
        panel: AppColors.dashDarkPanel,
        raised: AppColors.dashDarkPanelRaised,
        border: AppColors.dashDarkBorder,
        primary: AppColors.dashDarkPrimary,
        success: AppColors.dashSuccess,
        warning: AppColors.dashWarning,
        danger: AppColors.dashDanger,
        textPrimary: AppColors.dashDarkTextPrimary,
        textSecondary: AppColors.dashDarkTextSecondary,
        textMuted: AppColors.dashDarkTextMuted,
      );
    }

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

class DashboardBeamFrame extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double borderWidth;
  final double borderRadius;
  final Duration duration;

  const DashboardBeamFrame({
    super.key,
    required this.child,
    required this.enabled,
    this.borderWidth = 2,
    this.borderRadius = 10,
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<DashboardBeamFrame> createState() => _DashboardBeamFrameState();
}

class _DashboardBeamFrameState extends State<DashboardBeamFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant DashboardBeamFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.duration != widget.duration) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.enabled) {
      _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);
    final radius = BorderRadius.circular(widget.borderRadius);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 0.5 - 0.5 * math.cos(_controller.value * math.pi * 2);
        final glowStrength = 0.36 + (pulse * 0.3);
        final decoration = BoxDecoration(
          borderRadius: radius,
          color: widget.enabled ? null : palette.border.withValues(alpha: 0.08),
          gradient: widget.enabled
              ? SweepGradient(
                  transform: GradientRotation(_controller.value * math.pi * 2),
                  colors: [
                    Colors.transparent,
                    palette.primary.withValues(
                      alpha: 0.46 + glowStrength * 0.32,
                    ),
                    palette.success.withValues(
                      alpha: 0.34 + glowStrength * 0.28,
                    ),
                    palette.danger.withValues(alpha: 0.36 + glowStrength * 0.3),
                    palette.warning.withValues(
                      alpha: 0.32 + glowStrength * 0.28,
                    ),
                    palette.primary.withValues(
                      alpha: 0.24 + glowStrength * 0.24,
                    ),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.14, 0.31, 0.48, 0.65, 0.82, 1.0],
                )
              : null,
          boxShadow: widget.enabled
              ? [
                  BoxShadow(
                    color: palette.primary.withValues(
                      alpha: 0.12 + pulse * 0.12,
                    ),
                    blurRadius: 12 + pulse * 10,
                    spreadRadius: 0.3 + pulse * 0.8,
                  ),
                ]
              : null,
        );

        return DecoratedBox(
          decoration: decoration,
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
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
