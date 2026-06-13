import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/locations.dart';
import '../../providers/poller_provider.dart';
import '../../providers/search_params_provider.dart';
import '../widgets/section_card.dart';

const _intervalOptions = [10, 15, 20, 30, 45, 60, 90, 120];

class ControlPanel extends ConsumerStatefulWidget {
  const ControlPanel({super.key});

  @override
  ConsumerState<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends ConsumerState<ControlPanel> {
  @override
  Widget build(BuildContext context) {
    final ps = ref.watch(searchParamsProvider);
    final paramsNotifier = ref.read(searchParamsProvider.notifier);
    final pollerState = ref.watch(pollerProvider);
    final pollerNotifier = ref.read(pollerProvider.notifier);

    final isRunning = pollerState.running;
    final progress = pollerState.tickTotal > 0
        ? (pollerState.tickElapsed / pollerState.tickTotal).clamp(0.0, 1.0)
        : 0.0;
    final l = AppLocalizations.of(context)!;

    return SectionCard(
      title: l.sectionControl,
      icon: Icons.timer_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          _StatusBadge(msg: pollerState.statusMsg, running: isRunning),
          const SizedBox(height: 12),

          // Interval + Stop mode (same row)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, l.labelInterval),
                    DropdownButtonFormField<int>(
                      value: _intervalOptions.contains(ps.intervalSec)
                          ? ps.intervalSec
                          : _intervalOptions[1],
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      isExpanded: true,
                      items: _intervalOptions
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(l.unitSeconds(s)),
                            ),
                          )
                          .toList(),
                      onChanged: isRunning
                          ? null
                          : (v) {
                              if (v != null) paramsNotifier.updateInterval(v);
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, l.labelStopMode),
                    DropdownButtonFormField<String>(
                      value: ps.stopMode,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 'never',
                          child: Text(
                            l.stopModeNever,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'attempts',
                          child: Text(
                            l.stopModeAttempts,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'minutes',
                          child: Text(
                            l.stopModeMinutes,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'matches',
                          child: Text(
                            l.stopModeMatches,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: isRunning
                          ? null
                          : (v) {
                              if (v != null)
                                paramsNotifier.updateStopMode(v, ps.stopValue);
                            },
                    ),
                  ],
                ),
              ),
              if (ps.stopMode != 'never') ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    enabled: !isRunning,
                    initialValue: ps.stopValue.toString(),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n > 0)
                        paramsNotifier.updateStopMode(ps.stopMode, n);
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Countdown
          if (isRunning) ...[
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text(
              l.nextCheckLabel(
                (pollerState.tickTotal - pollerState.tickElapsed).ceil(),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
          ],

          // Buttons
          Row(
            children: [
              Expanded(
                child: isRunning
                    ? OutlinedButton.icon(
                        icon: const Icon(Icons.stop),
                        label: Text(l.btnStopMonitor),
                        onPressed: pollerNotifier.stop,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      )
                    : FilledButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l.btnStartMonitor),
                        onPressed: ps.hotelCodes.isEmpty
                            ? null
                            : () => pollerNotifier.start(ps, kHotelNames),
                      ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: '清除全部',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => ref.read(pollerProvider.notifier).clearAll(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium),
  );
}

class _StatusBadge extends StatelessWidget {
  final String msg;
  final bool running;
  const _StatusBadge({required this.msg, required this.running});

  @override
  Widget build(BuildContext context) {
    final color = running
        ? Colors.green
        : msg.contains('?�到')
        ? Colors.amber
        : Theme.of(context).colorScheme.outline;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            msg,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
