import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/date_scan_service.dart';

// ── Date Scan State ────────────────────────────────────────────

class DateScanState {
  final bool scanning;
  final List<DateScanResult> results;
  final String? error;

  const DateScanState({
    this.scanning = false,
    this.results = const [],
    this.error,
  });

  DateScanState copyWith({
    bool? scanning,
    List<DateScanResult>? results,
    String? error,
  }) {
    return DateScanState(
      scanning: scanning ?? this.scanning,
      results: results ?? this.results,
      error: error,
    );
  }
}

class DateScanNotifier extends Notifier<DateScanState> {
  final _service = DateScanService();

  @override
  DateScanState build() => const DateScanState();

  Future<void> scan({
    required String startDate,
    required String endDate,
    required List<String> hotelCodes,
    required Map<String, String> hotelNames,
    int numPeople = 1,
    int numRooms = 1,
    String smokingType = 'all',
  }) async {
    state = const DateScanState(scanning: true);

    final results = <DateScanResult>[];
    try {
      await for (final result in _service.scan(
        startDate: startDate,
        endDate: endDate,
        hotelCodes: hotelCodes,
        nights: 1,
        numPeople: numPeople,
        numRooms: numRooms,
        smokingType: smokingType,
        hotelNames: hotelNames,
      )) {
        results.add(result);
        state = state.copyWith(results: List.from(results));
      }
      state = state.copyWith(scanning: false);
    } catch (e) {
      state = DateScanState(
        scanning: false,
        results: results,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = const DateScanState();
  }
}

final dateScanProvider = NotifierProvider<DateScanNotifier, DateScanState>(
  DateScanNotifier.new,
);
