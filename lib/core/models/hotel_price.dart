import '../../utils/date_utils.dart';
import '../../utils/app_colors.dart';
import 'package:flutter/material.dart';

/// 單間飯店的報價快照
class HotelPrice {
  final String code;
  final String name;
  final int price; // 0 = 無報價
  final bool vacant; // existEnoughVacantRooms
  final bool maintenance; // isUnderMaintenance
  final List<String> unavailableDates;
  final bool nightlyAvailabilityChecked;

  const HotelPrice({
    required this.code,
    required this.name,
    required this.price,
    required this.vacant,
    required this.maintenance,
    this.unavailableDates = const [],
    this.nightlyAvailabilityChecked = false,
  });

  /// 真正可訂房：有報價 + 有足夠空房 + 不在維護中
  bool get available => price > 0 && vacant && !maintenance;

  String get priceStr => formatPrice(price);

  String get statusIcon {
    if (maintenance) return '🔧';
    if (price <= 0) return '─';
    if (!vacant) return '⚠';
    return '✓';
  }

  Color get statusColor {
    if (maintenance) return AppColors.maintenance;
    if (price <= 0) return AppColors.noRoom;
    if (!vacant) return AppColors.warning;
    return AppColors.available;
  }

  HotelPrice copyWith({
    List<String>? unavailableDates,
    bool? nightlyAvailabilityChecked,
  }) {
    return HotelPrice(
      code: code,
      name: name,
      price: price,
      vacant: vacant,
      maintenance: maintenance,
      unavailableDates: unavailableDates ?? this.unavailableDates,
      nightlyAvailabilityChecked:
          nightlyAvailabilityChecked ?? this.nightlyAvailabilityChecked,
    );
  }

  HotelPrice withNightlyAvailability({
    required List<String> stayDates,
    required List<HotelPrice?> nightlyPrices,
  }) {
    if (stayDates.length != nightlyPrices.length) {
      throw ArgumentError(
        'Stay dates and nightly prices must have equal length',
      );
    }

    return copyWith(
      unavailableDates: [
        for (var index = 0; index < stayDates.length; index++)
          if (nightlyPrices[index]?.available != true) stayDates[index],
      ],
      nightlyAvailabilityChecked: true,
    );
  }

  factory HotelPrice.fromJson(
    String code,
    Map<String, dynamic> json,
    String name,
  ) {
    return HotelPrice(
      code: code,
      name: name,
      price: (json['lowestPrice'] as num?)?.toInt() ?? 0,
      vacant: json['existEnoughVacantRooms'] as bool? ?? false,
      maintenance: json['isUnderMaintenance'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'HotelPrice($code, $name, $priceStr)';
}
