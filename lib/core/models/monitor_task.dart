import 'hotel_price.dart';
import 'search_params.dart';

enum TaskStatus { idle, running, matched, stopped, error }

/// 一個監控任務
class MonitorTask {
  final String id;
  final String name;
  final SearchParams params;
  final TaskStatus status;
  final int? latestLowestPrice;
  final HotelPrice? lowestPriceHotel;
  final DateTime createdAt;
  final DateTime? lastPolledAt;
  final List<HotelPrice> matchedHotels;

  const MonitorTask({
    required this.id,
    required this.name,
    required this.params,
    this.status = TaskStatus.idle,
    this.latestLowestPrice,
    this.lowestPriceHotel,
    required this.createdAt,
    this.lastPolledAt,
    this.matchedHotels = const [],
  });

  MonitorTask copyWith({
    TaskStatus? status,
    int? latestLowestPrice,
    HotelPrice? lowestPriceHotel,
    DateTime? lastPolledAt,
    List<HotelPrice>? matchedHotels,
  }) {
    return MonitorTask(
      id: id,
      name: name,
      params: params,
      status: status ?? this.status,
      latestLowestPrice: latestLowestPrice ?? this.latestLowestPrice,
      lowestPriceHotel: lowestPriceHotel ?? this.lowestPriceHotel,
      createdAt: createdAt,
      lastPolledAt: lastPolledAt ?? this.lastPolledAt,
      matchedHotels: matchedHotels ?? this.matchedHotels,
    );
  }
}
