import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/hotel_catalog_service.dart';

final hotelCatalogServiceProvider = Provider<HotelCatalogService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

enum HotelCatalogUpdateStatus { idle, updating, updated, failed }

class HotelCatalogUpdateState {
  const HotelCatalogUpdateState({
    this.status = HotelCatalogUpdateStatus.idle,
    this.hotelCount,
    this.updatedAt,
  });

  final HotelCatalogUpdateStatus status;
  final int? hotelCount;
  final DateTime? updatedAt;
}

final hotelCatalogUpdateProvider =
    StateNotifierProvider<HotelCatalogUpdateNotifier, HotelCatalogUpdateState>((
      ref,
    ) {
      return HotelCatalogUpdateNotifier(ref.read(hotelCatalogServiceProvider));
    });

class HotelCatalogUpdateNotifier
    extends StateNotifier<HotelCatalogUpdateState> {
  HotelCatalogUpdateNotifier(this._service)
    : super(HotelCatalogUpdateState(updatedAt: _service.updatedAt));

  final HotelCatalogService _service;

  Future<void> update() async {
    state = HotelCatalogUpdateState(
      status: HotelCatalogUpdateStatus.updating,
      updatedAt: state.updatedAt,
    );
    try {
      final count = await _service.update();
      state = HotelCatalogUpdateState(
        status: HotelCatalogUpdateStatus.updated,
        hotelCount: count,
        updatedAt: _service.updatedAt,
      );
    } catch (_) {
      state = HotelCatalogUpdateState(
        status: HotelCatalogUpdateStatus.failed,
        updatedAt: state.updatedAt,
      );
    }
  }
}
