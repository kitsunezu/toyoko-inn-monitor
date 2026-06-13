import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/monitor_task.dart';
import '../../data/locations.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/tasks_provider.dart';
import '../../utils/url_utils.dart';
import '../panels/tasks_panel.dart';
import 'dashboard_style.dart';

class ActiveMonitorPanel extends ConsumerWidget {
  final MonitorTask? task;

  const ActiveMonitorPanel({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final currentTask = task;

    if (currentTask == null) {
      return DashboardPanel(
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fillHeight = constraints.hasBoundedHeight;
            final emptyState = DashboardEmptyState(
              icon: Icons.monitor_heart_outlined,
              title: l.dashboardNoMonitorTasks,
              message: l.dashboardNoMonitorTasksMessage,
              action: FilledButton.icon(
                onPressed: () => showAddTaskDialog(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l.btnAddTask),
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: DashboardSectionTitle(
                    title: l.dashboardNavActiveMonitors,
                    subtitle: l.dashboardNoMonitorTasks,
                  ),
                ),
                Divider(height: 1, color: palette.border),
                if (fillHeight)
                  Expanded(child: emptyState)
                else
                  SizedBox(height: 260, child: emptyState),
              ],
            );
          },
        ),
      );
    }

    final status = _TaskStatusView.from(currentTask, palette, l);
    final running =
        currentTask.status == TaskStatus.running ||
        currentTask.status == TaskStatus.matched;
    final primaryHotelCode = _primaryHotelCode(currentTask);

    return DashboardPanel(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, panelConstraints) {
          final fillHeight = panelConstraints.hasBoundedHeight;
          final body = Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final stretchBody = constraints.hasBoundedHeight;
                final overview = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PriceOverview(task: currentTask, status: status),
                    const SizedBox(height: 12),
                    _TaskDetails(task: currentTask),
                  ],
                );
                final hotels = _HotelLinks(task: currentTask);

                if (compact) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [overview, const SizedBox(height: 12), hotels],
                    ),
                  );
                }

                return Row(
                  crossAxisAlignment: stretchBody
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: overview),
                    const SizedBox(width: 12),
                    Expanded(flex: 5, child: hotels),
                  ],
                );
              },
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.13),
                        border: Border.all(
                          color: status.color.withValues(alpha: 0.28),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.monitor_heart_outlined,
                        color: status.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.dashboardNavActiveMonitors,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            currentTask.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ActionIconButton(
                      tooltip: l.editTaskTooltip,
                      icon: Icons.edit_outlined,
                      color: palette.primary,
                      onPressed: () =>
                          showEditTaskDialog(context, ref, currentTask),
                    ),
                    _ActionIconButton(
                      tooltip: running ? l.dashboardPause : l.dashboardRun,
                      icon: running ? Icons.pause : Icons.play_arrow,
                      color: running ? palette.warning : palette.success,
                      onPressed: () {
                        if (running) {
                          ref
                              .read(tasksProvider.notifier)
                              .stopTask(currentTask.id);
                        } else {
                          ref
                              .read(tasksProvider.notifier)
                              .startTask(currentTask.id, kHotelNames);
                        }
                      },
                    ),
                    _ActionIconButton(
                      tooltip: l.dashboardOpenBooking,
                      icon: Icons.open_in_new,
                      color: palette.primary,
                      onPressed: primaryHotelCode == null
                          ? null
                          : () => _openHotelCode(currentTask, primaryHotelCode),
                    ),
                    _ActionIconButton(
                      tooltip: l.btnDelete,
                      icon: Icons.delete_outline,
                      color: palette.danger,
                      onPressed: () =>
                          _confirmDelete(context, ref, currentTask),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: palette.border),
              if (fillHeight) Expanded(child: body) else body,
            ],
          );
        },
      ),
    );
  }

  static String? _primaryHotelCode(MonitorTask task) {
    final lowest = task.lowestPriceHotel;
    if (lowest != null) return lowest.code;
    if (task.params.hotelCodes.isEmpty) return null;
    return task.params.hotelCodes.first;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MonitorTask task,
  ) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.dashboardDeleteMonitorTitle),
        content: Text(l.dashboardDeleteMonitorConfirm(task.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.btnDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(tasksProvider.notifier).deleteTask(task.id);
    }
  }
}

class _PriceOverview extends StatelessWidget {
  final MonitorTask task;
  final _TaskStatusView status;

  const _PriceOverview({required this.task, required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final priceColor = _priceColor(task, palette);
    final lowestHotel = task.lowestPriceHotel;
    final canOpenLowest = lowestHotel != null && lowestHotel.price > 0;

    Widget buildPanel({VoidCallback? onTap}) {
      return Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: palette.raised.withValues(alpha: 0.72),
            border: Border.all(color: palette.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: onTap,
            mouseCursor: onTap == null
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _PriceOverviewContent(
                task: task,
                status: status,
                priceColor: priceColor,
              ),
            ),
          ),
        ),
      );
    }

    if (!canOpenLowest) return buildPanel();

    return Tooltip(
      message: l.dashboardOpenBooking,
      child: buildPanel(onTap: () => _openHotelCode(task, lowestHotel.code)),
    );
  }

  static Color _priceColor(MonitorTask task, DashboardPalette palette) {
    final price = task.latestLowestPrice;
    if (price == null) return palette.textSecondary;
    final targetPrice = task.params.targetPrice;
    if (targetPrice == null) return palette.success;
    if (price <= targetPrice) return palette.success;
    if (price <= targetPrice * 1.1) return palette.warning;
    return palette.danger;
  }
}

class _PriceOverviewContent extends StatelessWidget {
  final MonitorTask task;
  final _TaskStatusView status;
  final Color priceColor;

  const _PriceOverviewContent({
    required this.task,
    required this.status,
    required this.priceColor,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stretchVertically =
            constraints.hasBoundedHeight && constraints.maxHeight >= 220;
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
        final columns = width >= 560
            ? 3
            : width >= 360
            ? 2
            : 1;
        final tileWidth = constraints.hasBoundedWidth
            ? (width - (columns - 1) * 8) / columns
            : null;
        final infoPills = [
          _InfoPill(
            label: l.labelTargetShort,
            value: compactPrice(task.params.targetPrice),
            icon: Icons.adjust,
          ),
          _InfoPill(
            label: l.dashboardColumnVsTarget,
            value: _gapText(task),
            icon: Icons.compare_arrows,
            valueColor: _gapColor(task, palette),
          ),
          _InfoPill(
            label: l.dashboardLastUpdated,
            value:
                '${compactDate(task.lastPolledAt)} ${compactTime(task.lastPolledAt)}',
            icon: Icons.update,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.dashboardMetricLowestPrice,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        compactPrice(task.latestLowestPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: priceColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.lowestPriceHotel?.name ??
                            l.dashboardNoStoredPrices,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: status),
              ],
            ),
            if (stretchVertically)
              const Spacer()
            else
              const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final pill in infoPills)
                  if (tileWidth == null)
                    pill
                  else
                    SizedBox(width: tileWidth, child: pill),
              ],
            ),
          ],
        );
      },
    );
  }

  static String _gapText(MonitorTask task) {
    final price = task.latestLowestPrice;
    if (price == null) return '--';
    final targetPrice = task.params.targetPrice;
    if (targetPrice == null) return '--';
    final gap = price - targetPrice;
    final prefix = gap <= 0 ? '-' : '+';
    final absolute = gap.abs().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final percent = targetPrice <= 0
        ? 0
        : ((gap.abs() / targetPrice) * 100).round();
    return '$prefix JPY $absolute ($percent%)';
  }

  static Color _gapColor(MonitorTask task, DashboardPalette palette) {
    final price = task.latestLowestPrice;
    if (price == null) return palette.textMuted;
    final targetPrice = task.params.targetPrice;
    if (targetPrice == null) return palette.textMuted;
    if (price <= targetPrice) return palette.success;
    if (price <= targetPrice * 1.1) return palette.warning;
    return palette.danger;
  }
}

class _TaskDetails extends StatelessWidget {
  final MonitorTask task;

  const _TaskDetails({required this.task});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
        final columns = width >= 420 ? 2 : 1;
        final tileWidth = constraints.hasBoundedWidth
            ? (width - (columns - 1) * 8) / columns
            : null;
        final tiles = [
          _DetailTile(
            label: l.labelLocation,
            value: task.params.location,
            width: tileWidth,
          ),
          _DetailTile(
            label: l.labelCheckin,
            value: '${task.params.checkin} (${_nights(task, l)})',
            width: tileWidth,
          ),
          _DetailTile(
            label: l.dashboardCheckOut,
            value: task.params.checkout,
            width: tileWidth,
          ),
          _DetailTile(
            label: l.dashboardRoomGuestSummary(
              task.params.numRooms,
              task.params.numPeople,
            ),
            value: _smokingLabel(task.params.smokingType, l),
            width: tileWidth,
          ),
          _DetailTile(
            label: l.labelInterval,
            value: l.unitSeconds(task.params.intervalSec),
            width: tileWidth,
          ),
          _DetailTile(
            label: l.labelStopMode,
            value: _stopModeLabel(task.params.stopMode, l),
            width: tileWidth,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(l.dashboardTaskDetails),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: tiles),
          ],
        );
      },
    );
  }

  static String _nights(MonitorTask task, AppLocalizations l) {
    final checkin = DateTime.tryParse(task.params.checkin);
    final checkout = DateTime.tryParse(task.params.checkout);
    if (checkin == null || checkout == null) return l.dashboardNotAvailable;
    final nights = checkout.difference(checkin).inDays;
    return l.dashboardNights(nights);
  }

  static String _smokingLabel(String value, AppLocalizations l) {
    return switch (value) {
      'smoking' => l.optionSmoking,
      _ => l.optionNoSmoking,
    };
  }

  static String _stopModeLabel(String value, AppLocalizations l) {
    return switch (value) {
      'attempts' => l.stopModeAttempts,
      'minutes' => l.stopModeMinutes,
      'matches' => l.stopModeMatches,
      _ => l.stopModeNever,
    };
  }
}

class _HotelLinks extends StatelessWidget {
  final MonitorTask task;

  const _HotelLinks({required this.task});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final selected = task.params.hotelCodes;
    final matches = task.matchedHotels;
    final latestByCode = {
      for (final hotel in task.latestHotelPrices) hotel.code: hotel,
    };
    final originalIndex = {
      for (var index = 0; index < selected.length; index++)
        selected[index]: index,
    };
    final matchedCodes = matches.map((hotel) => hotel.code).toSet();
    final sortedSelected = [...selected]
      ..sort((a, b) {
        final aPrice = latestByCode[a]?.price ?? 0;
        final bPrice = latestByCode[b]?.price ?? 0;
        final aHasPrice = aPrice > 0;
        final bHasPrice = bPrice > 0;

        if (aHasPrice != bHasPrice) {
          return aHasPrice ? -1 : 1;
        }

        final priceCompare = aPrice.compareTo(bPrice);
        if (priceCompare != 0) return priceCompare;

        return (originalIndex[a] ?? 0).compareTo(originalIndex[b] ?? 0);
      });

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.raised.withValues(alpha: 0.45),
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fillHeight = constraints.hasBoundedHeight;
          final emptyState = Text(
            l.dashboardNotAvailable,
            style: TextStyle(color: palette.textMuted, fontSize: 12),
          );
          final list = ListView.separated(
            shrinkWrap: !fillHeight,
            physics: fillHeight ? null : const NeverScrollableScrollPhysics(),
            itemCount: sortedSelected.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: palette.border),
            itemBuilder: (context, index) {
              final code = sortedSelected[index];
              final latest = latestByCode[code];
              return _HotelLinkRow(
                code: code,
                name: latest?.name ?? kHotelNames[code] ?? code,
                task: task,
                price: compactPrice(latest?.price),
                highlight: matchedCodes.contains(code),
              );
            },
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(l.dashboardSelectedHotels),
              const SizedBox(height: 8),
              if (selected.isEmpty)
                if (fillHeight)
                  Expanded(child: Center(child: emptyState))
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: emptyState,
                  )
              else if (fillHeight)
                Expanded(child: list)
              else
                list,
            ],
          );
        },
      ),
    );
  }
}

class _HotelLinkRow extends StatelessWidget {
  final String code;
  final String name;
  final MonitorTask task;
  final String? price;
  final bool highlight;

  const _HotelLinkRow({
    required this.code,
    required this.name,
    required this.task,
    this.price,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = DashboardPalette.of(context);
    final color = highlight ? palette.success : palette.primary;

    return Tooltip(
      message: l.dashboardOpenBooking,
      child: InkWell(
        onTap: () => _openHotelCode(task, code),
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.hotel_outlined, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: color.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (price != null)
                Text(
                  price!,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else
                Text(
                  code,
                  style: TextStyle(color: palette.textMuted, fontSize: 11),
                ),
              const SizedBox(width: 6),
              Icon(Icons.open_in_new, size: 13, color: palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _TaskStatusView status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        border: Border.all(color: status.color.withValues(alpha: 0.26)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(color: status.color, size: 7),
          const SizedBox(width: 7),
          Text(
            status.label,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoPill({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 144),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: palette.textMuted),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textMuted, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor ?? palette.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final double? width;

  const _DetailTile({required this.label, required this.value, this.width});

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);

    return SizedBox(
      width: width ?? 176,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: palette.raised.withValues(alpha: 0.55),
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textMuted, fontSize: 10),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: palette.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = DashboardPalette.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 18,
          color: color,
          disabledColor: palette.textMuted.withValues(alpha: 0.55),
          style: IconButton.styleFrom(
            fixedSize: const Size(34, 34),
            padding: EdgeInsets.zero,
            backgroundColor: onPressed == null
                ? palette.raised.withValues(alpha: 0.4)
                : color.withValues(alpha: 0.11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskStatusView {
  final String label;
  final Color color;

  const _TaskStatusView(this.label, this.color);

  factory _TaskStatusView.from(
    MonitorTask task,
    DashboardPalette palette,
    AppLocalizations l,
  ) {
    return switch (task.status) {
      TaskStatus.running => _TaskStatusView(
        l.dashboardRunning,
        palette.success,
      ),
      TaskStatus.matched => _TaskStatusView(l.dashboardAlert, palette.danger),
      TaskStatus.stopped => _TaskStatusView(l.dashboardPaused, palette.warning),
      TaskStatus.error => _TaskStatusView(l.dashboardError, palette.danger),
      TaskStatus.idle => _TaskStatusView(l.dashboardPaused, palette.warning),
    };
  }
}

Future<void> _openHotelCode(MonitorTask task, String hotelCode) async {
  final url = buildBookingUrl(
    hotelCode: hotelCode,
    checkin: task.params.checkin,
    checkout: task.params.checkout,
    rooms: task.params.numRooms,
    people: task.params.numPeople,
    smokingType: task.params.smokingType,
  );
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
