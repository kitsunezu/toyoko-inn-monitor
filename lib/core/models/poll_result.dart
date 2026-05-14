import 'hotel_price.dart';

/// 一輪查詢的完整結果
class PollResult {
  final DateTime timestamp;
  final int attempt;
  final List<HotelPrice> hotels;
  final List<HotelPrice> matches;
  final String? error;

  const PollResult({
    required this.timestamp,
    required this.attempt,
    required this.hotels,
    this.matches = const [],
    this.error,
  });

  bool get success => error == null;

  factory PollResult.error({
    required int attempt,
    required String message,
  }) {
    return PollResult(
      timestamp: DateTime.now(),
      attempt: attempt,
      hotels: const [],
      matches: const [],
      error: message,
    );
  }
}
