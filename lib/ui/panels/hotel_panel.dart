import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/locations.dart';
import '../../providers/search_params_provider.dart';
import '../widgets/section_card.dart';

class HotelPanel extends ConsumerStatefulWidget {
  const HotelPanel({super.key});

  @override
  ConsumerState<HotelPanel> createState() => _HotelPanelState();
}

class _HotelPanelState extends ConsumerState<HotelPanel> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _filter = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(searchParamsProvider);
    final notifier = ref.read(searchParamsProvider.notifier);
    final allCodes = kLocations[p.location] ?? [];
    final selected = Set<String>.from(p.hotelCodes);
    final l = AppLocalizations.of(context)!;

    final filtered = allCodes.where((code) {
      if (_filter.isEmpty) return true;
      final name = (kHotelNames[code] ?? code).toLowerCase();
      return name.contains(_filter) || code.contains(_filter);
    }).toList();

    return SectionCard(
      title: l.sectionHotels(selected.length, allCodes.length),
      icon: Icons.hotel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search filter
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: l.hintHotelSearch,
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _filter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 8),

          // Select all / none
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.select_all, size: 16),
                label: Text(l.btnSelectAll),
                onPressed: () {
                  notifier.updateHotelCodes(List.from(allCodes));
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.deselect, size: 16),
                label: Text(l.btnSelectNone),
                onPressed: () {
                  notifier.updateHotelCodes([]);
                },
              ),
            ],
          ),

          // Hotel list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final code = filtered[i];
                final name = kHotelNames[code] ?? code;
                final isSelected = selected.contains(code);
                return CheckboxListTile(
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(name, style: const TextStyle(fontSize: 13)),
                  subtitle: Text(
                    code,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  value: isSelected,
                  onChanged: (v) {
                    final newSelected = Set<String>.from(selected);
                    if (v == true) {
                      newSelected.add(code);
                    } else {
                      newSelected.remove(code);
                    }
                    notifier.updateHotelCodes(newSelected.toList());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
