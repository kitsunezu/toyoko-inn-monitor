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

  const HotelPrice({
    required this.code,
    required this.name,
    required this.price,
    required this.vacant,
    required this.maintenance,
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
