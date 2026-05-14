import 'package:intl/intl.dart';

/// 將 YYYY-MM-DD (JST 日期) 轉為 API 所需 UTC 格式。
/// 例: '2026-03-20' → '2026-03-19T16:00:00.000Z'
/// 原理: 日本日期 01:00 JST = 前一天 16:00 UTC
String toApiDate(String dateStr) {
  final parts = dateStr.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final day = int.parse(parts[2]);
  // 日本 JST = UTC+9，取 01:00 JST = 16:00 UTC 前一天
  final jst = DateTime(year, month, day, 1, 0, 0);
  final utc = jst.subtract(const Duration(hours: 9));
  return '${utc.year.toString().padLeft(4, '0')}'
      '-${utc.month.toString().padLeft(2, '0')}'
      '-${utc.day.toString().padLeft(2, '0')}'
      'T${utc.hour.toString().padLeft(2, '0')}:00:00.000Z';
}

/// 將 DateTime 格式化為 YYYY-MM-DD 字串
String formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

/// 將 DateTime 格式化為 HH:mm 字串
String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

/// 將 DateTime 格式化為 HH:mm:ss 字串
String formatTimestamp(DateTime dt) => DateFormat('HH:mm:ss').format(dt);

/// 計算退房日期 (checkin + nights)
String checkoutDate(String checkin, int nights) {
  final parts = checkin.split('-');
  final dt = DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  ).add(Duration(days: nights));
  return formatDate(dt);
}

/// 價格格式化：'¥5,200' 或 (0 → '無報價')
String formatPrice(int price, {String locale = 'zh_TW'}) {
  if (price <= 0) return '無報價';
  return '¥${NumberFormat('#,###').format(price)}';
}
