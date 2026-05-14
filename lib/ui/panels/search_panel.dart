import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/locations.dart';
import '../../providers/search_params_provider.dart';
import '../../utils/date_utils.dart';
import '../widgets/section_card.dart';

class SearchPanel extends ConsumerStatefulWidget {
  const SearchPanel({super.key});

  @override
  ConsumerState<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<SearchPanel> {
  late TextEditingController _targetCtrl;
  int _nights = 1;

  @override
  void initState() {
    super.initState();
    final p = ref.read(searchParamsProvider);
    _targetCtrl = TextEditingController(text: p.targetPrice.toString());
    // 計�? nights from checkin/checkout
    try {
      final cin = DateTime.parse(p.checkin);
      final cout = DateTime.parse(p.checkout);
      _nights = cout.difference(cin).inDays.clamp(1, 14);
    } catch (_) {
      _nights = 1;
    }
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(searchParamsProvider);
    final notifier = ref.read(searchParamsProvider.notifier);

    final l = AppLocalizations.of(context)!;
    return SectionCard(
      title: l.sectionSearch,
      icon: Icons.search,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location
          _label(l.labelLocation),
          DropdownButtonFormField<String>(
            value: p.location,
            decoration: _dec(),
            isExpanded: true,
            items: kLocations.keys
                .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                .toList(),
            onChanged: (v) {
              if (v != null) notifier.updateLocation(v);
            },
          ),
          const SizedBox(height: 8),

          // Check-in date + Nights (same row)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(l.labelCheckin),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _pickDate(context, p.checkin, notifier),
                      child: InputDecorator(
                        decoration: _dec(),
                        child: Text(p.checkin),
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
                    _label(l.labelNights),
                    _StepperRow(
                      value: _nights,
                      min: 1,
                      max: 14,
                      onChanged: (v) {
                        setState(() => _nights = v);
                        notifier.updateCheckin(p.checkin, v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // People & Rooms
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(l.labelPeople),
                    _StepperRow(
                      value: p.numPeople,
                      min: 1,
                      max: 6,
                      onChanged: notifier.updateNumPeople,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(l.labelRooms),
                    _StepperRow(
                      value: p.numRooms,
                      min: 1,
                      max: 4,
                      onChanged: notifier.updateNumRooms,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(l.labelRoomType),
                    DropdownButtonFormField<String>(
                      value: p.smokingType,
                      isExpanded: true,
                      decoration: _dec(),
                      items: [
                        DropdownMenuItem(
                            value: 'noSmoking', child: Text(l.optionNoSmoking, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(
                            value: 'smoking', child: Text(l.optionSmoking, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) {
                        if (v != null) notifier.updateSmokingType(v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Target price
          _label(l.labelTargetPrice),
          TextFormField(
            controller: _targetCtrl,
            decoration: _dec(hint: l.hintTargetPrice),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n > 0) notifier.updateTargetPrice(n);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    String current,
    SearchParamsNotifier notifier,
  ) async {
    DateTime initial;
    try {
      initial = DateTime.parse(current);
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
      notifier.updateCheckin(formatDate(picked), _nights);
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium,
    ),
  );

  InputDecoration _dec({String? hint}) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}

// ?�?� Stepper widget ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

class _StepperRow extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperRow({
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
