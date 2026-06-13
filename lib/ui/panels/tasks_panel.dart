import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/hotel_price.dart';
import '../../core/models/monitor_task.dart';
import '../../core/models/search_params.dart';
import '../../data/locations.dart';
import '../../providers/tasks_provider.dart';
import '../../utils/date_utils.dart';
import '../../utils/app_colors.dart';
import '../../utils/url_utils.dart';

Future<MonitorTask?> showAddTaskDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final spec = await showDialog<_TaskSpec>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _TaskDialog(),
  );
  if (spec == null || !context.mounted) return null;

  return ref
      .read(tasksProvider.notifier)
      .createTask(spec.params, spec.name.isEmpty ? null : spec.name);
}

Future<MonitorTask?> showEditTaskDialog(
  BuildContext context,
  WidgetRef ref,
  MonitorTask task,
) async {
  final spec = await showDialog<_TaskSpec>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TaskDialog(initialTask: task),
  );
  if (spec == null || !context.mounted) return null;

  return ref
      .read(tasksProvider.notifier)
      .updateTask(
        task.id,
        spec.params,
        spec.name.isEmpty ? null : spec.name,
        hotelNames: kHotelNames,
      );
}

class TasksPanel extends ConsumerWidget {
  const TasksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final l = AppLocalizations.of(context)!;
    final task = tasks.isEmpty ? null : tasks.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.pageTasksTitle),
        actions: [
          IconButton(
            icon: Icon(task == null ? Icons.add : Icons.edit_outlined),
            tooltip: task == null ? l.addTaskTooltip : l.editTaskTooltip,
            onPressed: () => task == null
                ? showAddTaskDialog(context, ref)
                : showEditTaskDialog(context, ref, task),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.list_alt_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(l.noTasksMsg),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l.btnAddTask),
                    onPressed: () => showAddTaskDialog(context, ref),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final t in tasks)
                    SizedBox(width: 360, child: _TaskCard(task: t)),
                ],
              ),
            ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final MonitorTask task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final isRunning = task.status == TaskStatus.running;
    final isMatched = task.status == TaskStatus.matched;

    Color statusColor = isRunning
        ? AppColors.available
        : isMatched
        ? AppColors.match
        : cs.outline;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isRunning)
                  IconButton(
                    icon: const Icon(Icons.stop, size: 18),
                    tooltip: AppLocalizations.of(context)!.stopTaskTooltip,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    onPressed: () =>
                        ref.read(tasksProvider.notifier).stopTask(task.id),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    tooltip: AppLocalizations.of(context)!.startTaskTooltip,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    onPressed: () => ref
                        .read(tasksProvider.notifier)
                        .startTask(task.id, kHotelNames),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: AppLocalizations.of(context)!.editTaskTooltip,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  onPressed: () => showEditTaskDialog(context, ref, task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: AppLocalizations.of(context)!.deleteTaskTooltip,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  onPressed: () => _handleAction(context, ref, 'delete'),
                ),
              ],
            ),
            const Divider(height: 16),

            // Details
            _infoRow(Icons.location_on_outlined, task.params.location),
            const SizedBox(height: 4),
            _infoRow(
              Icons.calendar_today_outlined,
              '${task.params.checkin} → ${task.params.checkout}',
            ),
            const SizedBox(height: 4),
            _infoRow(
              Icons.flag_outlined,
              '${l.labelTargetShort}: ${task.params.targetPrice == null ? l.dashboardNotAvailable : formatPrice(task.params.targetPrice!)}',
            ),

            const SizedBox(height: 8),

            // Matched hotels
            if (isMatched && task.matchedHotels.isNotEmpty) ...[
              const Divider(height: 12),
              for (final h in task.matchedHotels)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () => _openMatchUrl(context, h, task.params),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            h.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.match,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          h.priceStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.match,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],

            // Latest lowest hotel (when not matched)
            if (!isMatched && task.lowestPriceHotel != null) ...[
              const Divider(height: 12),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () =>
                    _openMatchUrl(context, task.lowestPriceHotel!, task.params),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.lowestPriceHotel!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Text(
                      task.lowestPriceHotel!.priceStr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            task.params.targetPrice != null &&
                                task.lowestPriceHotel!.price <=
                                    task.params.targetPrice!
                            ? AppColors.match
                            : AppColors.available,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openMatchUrl(
    BuildContext context,
    HotelPrice h,
    SearchParams ps,
  ) async {
    final url = buildBookingUrl(
      hotelCode: h.code,
      checkin: ps.checkin,
      checkout: ps.checkout,
      rooms: ps.numRooms,
      people: ps.numPeople,
      smokingType: ps.smokingType,
    );
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    final notifier = ref.read(tasksProvider.notifier);
    switch (action) {
      case 'start':
        notifier.startTask(task.id, kHotelNames);
      case 'stop':
        notifier.stopTask(task.id);
      case 'delete':
        showDialog<bool>(
          context: context,
          builder: (ctx) {
            final l = AppLocalizations.of(ctx)!;
            return AlertDialog(
              title: Text(l.deleteTaskTitle),
              content: Text(l.deleteTaskConfirm(task.name)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.btnCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(l.btnDelete),
                ),
              ],
            );
          },
        ).then((confirmed) {
          if (confirmed == true) notifier.deleteTask(task.id);
        });
    }
  }
}

// ?�?� Task spec returned from dialog ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _TaskSpec {
  final String name;
  final SearchParams params;
  const _TaskSpec({required this.name, required this.params});
}

// ?�?� New Task Dialog ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

const _intervalOptions = [10, 15, 20, 30, 45, 60, 90, 120];

class _TaskDialog extends StatefulWidget {
  final MonitorTask? initialTask;

  const _TaskDialog({this.initialTask});

  bool get isEditing => initialTask != null;

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  late String _location;
  late List<String> _hotelCodes;
  late String _checkin;
  int _nights = 1;
  int _numPeople = 2;
  int _numRooms = 1;
  String _smokingType = 'noSmoking';
  int _intervalSec = 15;
  String _stopMode = 'never';
  int _stopValue = 100;

  String get _checkout => checkoutDate(_checkin, _nights);

  @override
  void initState() {
    super.initState();
    final initialTask = widget.initialTask;
    if (initialTask != null) {
      final params = initialTask.params;
      _location = kLocations.containsKey(params.location)
          ? params.location
          : kLocations.keys.first;
      _hotelCodes = List.from(params.hotelCodes);
      _checkin = params.checkin;
      _nights = _nightsBetween(params.checkin, params.checkout);
      _numPeople = params.numPeople;
      _numRooms = params.numRooms;
      _smokingType = params.smokingType == 'smoking' ? 'smoking' : 'noSmoking';
      _intervalSec = params.intervalSec;
      _stopMode = _stopModes.contains(params.stopMode)
          ? params.stopMode
          : 'never';
      _stopValue = params.stopValue > 0 ? params.stopValue : 100;
      _targetCtrl.text = params.targetPrice?.toString() ?? '';
      _nameCtrl.text = initialTask.name;
      return;
    }

    _location = kLocations.keys.first;
    _hotelCodes = List.from(kLocations[_location] ?? []);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _checkin = formatDate(tomorrow);
    _targetCtrl.text = '';
    _nameCtrl.text = '$_location $_checkin';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  SearchParams get _buildParams => SearchParams(
    location: _location,
    hotelCodes: _hotelCodes,
    checkin: _checkin,
    checkout: _checkout,
    numPeople: _numPeople,
    numRooms: _numRooms,
    smokingType: _smokingType,
    targetPrice: _targetPrice,
    intervalSec: _intervalSec,
    stopMode: _stopMode,
    stopValue: _stopValue,
  );

  int? get _targetPrice {
    final text = _targetCtrl.text.trim();
    if (text.isEmpty) return null;
    final value = int.tryParse(text);
    return value == null || value <= 0 ? null : value;
  }

  void _autoName() {
    _nameCtrl.text = '$_location $_checkin-$_checkout';
  }

  static const _stopModes = ['never', 'attempts', 'minutes', 'matches'];

  static int _nightsBetween(String checkin, String checkout) {
    final start = DateTime.tryParse(checkin);
    final end = DateTime.tryParse(checkout);
    if (start == null || end == null) return 1;
    final nights = end.difference(start).inDays;
    if (nights < 1) return 1;
    if (nights > 14) return 14;
    return nights;
  }

  Future<void> _pickDate() async {
    DateTime initial;
    try {
      initial = DateTime.parse(_checkin);
    } catch (_) {
      initial = DateTime.now().add(const Duration(days: 1));
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkin = formatDate(picked);
        _autoName();
      });
    }
  }

  void _submit() {
    if (_hotelCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noHotelSelected)),
      );
      return;
    }
    Navigator.pop(
      context,
      _TaskSpec(name: _nameCtrl.text.trim(), params: _buildParams),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium),
  );

  InputDecoration _dec({String? hint}) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  @override
  Widget build(BuildContext context) {
    final allCodes = kLocations[_location] ?? [];
    final selected = Set<String>.from(_hotelCodes);
    final intervalOptions = {..._intervalOptions, _intervalSec}.toList()
      ..sort();
    final l = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          children: [
            // Header
            AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                widget.isEditing ? l.dialogEditTask : l.dialogNewTask,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text(l.btnCancel),
                ),
                FilledButton(
                  onPressed: _submit,
                  child: Text(widget.isEditing ? l.btnSave : l.btnAdd),
                ),
                const SizedBox(width: 8),
              ],
            ),
            // Form body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Task name
                  _label(AppLocalizations.of(context)!.labelTaskName),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _dec(
                      hint: AppLocalizations.of(context)!.hintTaskName,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location
                  _label(AppLocalizations.of(context)!.labelLocation),
                  DropdownButtonFormField<String>(
                    value: _location,
                    decoration: _dec(),
                    isExpanded: true,
                    items: kLocations.keys
                        .map(
                          (loc) =>
                              DropdownMenuItem(value: loc, child: Text(loc)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _location = v;
                          _hotelCodes = List.from(kLocations[v] ?? []);
                          _autoName();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Check-in + Nights
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppLocalizations.of(context)!.labelCheckin),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: _dec(),
                                child: Text(_checkin),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppLocalizations.of(context)!.labelNights),
                            _MiniStepper(
                              value: _nights,
                              min: 1,
                              max: 14,
                              onChanged: (v) => setState(() {
                                _nights = v;
                                _autoName();
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // People + Rooms + Smoking
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppLocalizations.of(context)!.labelPeople),
                            _MiniStepper(
                              value: _numPeople,
                              min: 1,
                              max: 6,
                              onChanged: (v) => setState(() => _numPeople = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppLocalizations.of(context)!.labelRooms),
                            _MiniStepper(
                              value: _numRooms,
                              min: 1,
                              max: 4,
                              onChanged: (v) => setState(() => _numRooms = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppLocalizations.of(context)!.labelRoomType),
                            DropdownButtonFormField<String>(
                              value: _smokingType,
                              isExpanded: true,
                              decoration: _dec(),
                              items: [
                                DropdownMenuItem(
                                  value: 'noSmoking',
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.optionNoSmoking,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'smoking',
                                  child: Text(
                                    AppLocalizations.of(context)!.optionSmoking,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _smokingType = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Target price
                  _label(AppLocalizations.of(context)!.labelTargetPrice),
                  TextFormField(
                    controller: _targetCtrl,
                    decoration: _dec(
                      hint: AppLocalizations.of(context)!.hintTargetPrice,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // Interval + Stop mode
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppLocalizations.of(context)!.labelInterval),
                            DropdownButtonFormField<int>(
                              value: _intervalSec,
                              isExpanded: true,
                              decoration: _dec(),
                              items: intervalOptions
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.unitSeconds(s),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _intervalSec = v);
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
                            _label(AppLocalizations.of(context)!.labelStopMode),
                            DropdownButtonFormField<String>(
                              value: _stopMode,
                              isExpanded: true,
                              decoration: _dec(),
                              items: [
                                DropdownMenuItem(
                                  value: 'never',
                                  child: Text(
                                    AppLocalizations.of(context)!.stopModeNever,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'attempts',
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.stopModeAttempts,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'minutes',
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.stopModeMinutes,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'matches',
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.stopModeMatches,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _stopMode = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_stopMode != 'never') ...[
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('數量'),
                              TextFormField(
                                initialValue: _stopValue.toString(),
                                decoration: _dec(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null && n > 0)
                                    setState(() => _stopValue = n);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hotel selection
                  Row(
                    children: [
                      Text(
                        l.sectionHotels(selected.length, allCodes.length),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            setState(() => _hotelCodes = List.from(allCodes)),
                        child: Text(l.btnSelectAll),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _hotelCodes = []),
                        child: Text(l.btnSelectNone),
                      ),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allCodes.length,
                      itemBuilder: (context, i) {
                        final code = allCodes[i];
                        final name = kHotelNames[code] ?? code;
                        final isSel = selected.contains(code);
                        return CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            code,
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: isSel,
                          onChanged: (v) {
                            final next = Set<String>.from(selected);
                            if (v == true) {
                              next.add(code);
                            } else {
                              next.remove(code);
                            }
                            setState(() => _hotelCodes = next.toList());
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ?�?� Mini stepper widget (used in dialog) ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _MiniStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _MiniStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.remove),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          iconSize: 16,
        ),
        Expanded(
          child: Center(
            child: Text(
              '$value',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton.filledTonal(
          icon: const Icon(Icons.add),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          iconSize: 16,
        ),
      ],
    );
  }
}
