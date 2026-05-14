import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/search_params.dart';
import '../data/locations.dart';
import '../utils/date_utils.dart';
import 'settings_provider.dart';

/// 目前在編輯中的搜尋條件（未必在執行）
final searchParamsProvider =
    NotifierProvider<SearchParamsNotifier, SearchParams>(
  SearchParamsNotifier.new,
);

class SearchParamsNotifier extends Notifier<SearchParams> {
  @override
  SearchParams build() {
    final s = ref.read(settingsServiceProvider);
    final location = s.location;
    final codes = kLocations[location] ?? [];
    final savedCodes = s.selectedHotels;
    final checkin = s.checkin;
    final nights = s.nights;

    return SearchParams(
      location: location,
      hotelCodes: savedCodes.isNotEmpty ? savedCodes : codes,
      checkin: checkin,
      checkout: checkoutDate(checkin, nights),
      numPeople: s.numPeople,
      numRooms: s.numRooms,
      smokingType: s.smokingType,
      targetPrice: s.targetPrice,
      intervalSec: s.intervalSec,
      stopMode: s.stopMode,
      stopValue: s.stopValue,
    );
  }

  void update(SearchParams p) => state = p;

  void updateLocation(String location) {
    final codes = kLocations[location] ?? [];
    state = state.copyWith(location: location, hotelCodes: codes);
    _save();
  }

  void updateCheckin(String checkin, int nights) {
    state = state.copyWith(
      checkin: checkin,
      checkout: checkoutDate(checkin, nights),
    );
    _save();
  }

  void updateHotelCodes(List<String> codes) {
    state = state.copyWith(hotelCodes: codes);
    ref.read(settingsServiceProvider).setSelectedHotels(codes);
  }

  void updateNumPeople(int v) {
    state = state.copyWith(numPeople: v);
    _save();
  }

  void updateNumRooms(int v) {
    state = state.copyWith(numRooms: v);
    _save();
  }

  void updateSmokingType(String v) {
    state = state.copyWith(smokingType: v);
    _save();
  }

  void updateTargetPrice(int v) {
    state = state.copyWith(targetPrice: v);
    _save();
  }

  void updateInterval(int v) {
    state = state.copyWith(intervalSec: v);
    _save();
  }

  void updateStopMode(String mode, int value) {
    state = state.copyWith(stopMode: mode, stopValue: value);
    _save();
  }

  void _save() {
    final s = ref.read(settingsServiceProvider);
    final p = state;
    s.setLocation(p.location);
    s.setCheckin(p.checkin);
    s.setNumPeople(p.numPeople);
    s.setNumRooms(p.numRooms);
    s.setSmokingType(p.smokingType);
    s.setTargetPrice(p.targetPrice);
    s.setIntervalSec(p.intervalSec);
    s.setStopMode(p.stopMode);
    s.setStopValue(p.stopValue);
  }
}
