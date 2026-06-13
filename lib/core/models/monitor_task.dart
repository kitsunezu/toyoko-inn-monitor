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
  final List<HotelPrice> latestHotelPrices;
  final List<HotelPrice> matchedHotels;
  final double tickElapsed;
  final double tickTotal;

  const MonitorTask({
    required this.id,
    required this.name,
    required this.params,
    this.status = TaskStatus.idle,
    this.latestLowestPrice,
    this.lowestPriceHotel,
    required this.createdAt,
    this.lastPolledAt,
    this.latestHotelPrices = const [],
    this.matchedHotels = const [],
    this.tickElapsed = 0,
    this.tickTotal = 1,
  });

  MonitorTask copyWith({
    String? name,
    SearchParams? params,
    TaskStatus? status,
    int? latestLowestPrice,
    HotelPrice? lowestPriceHotel,
    DateTime? lastPolledAt,
    List<HotelPrice>? latestHotelPrices,
    List<HotelPrice>? matchedHotels,
    double? tickElapsed,
    double? tickTotal,
  }) {
    return MonitorTask(
      id: id,
      name: name ?? this.name,
      params: params ?? this.params,
      status: status ?? this.status,
      latestLowestPrice: latestLowestPrice ?? this.latestLowestPrice,
      lowestPriceHotel: lowestPriceHotel ?? this.lowestPriceHotel,
      createdAt: createdAt,
      lastPolledAt: lastPolledAt ?? this.lastPolledAt,
      latestHotelPrices: latestHotelPrices ?? this.latestHotelPrices,
      matchedHotels: matchedHotels ?? this.matchedHotels,
      tickElapsed: tickElapsed ?? this.tickElapsed,
      tickTotal: tickTotal ?? this.tickTotal,
    );
  }
}
