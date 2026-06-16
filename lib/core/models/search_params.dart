/// 使用者的搜尋條件
class SearchParams {
  final String location;
  final List<String> hotelCodes;
  final String checkin; // YYYY-MM-DD
  final String checkout; // YYYY-MM-DD
  final int numPeople; // 1-6
  final int numRooms; // 1-4
  final String smokingType; // 'all' | 'noSmoking' | 'smoking'
  final int? targetPrice; // null means monitor only
  final int intervalSec; // 查詢間隔 (秒)
  final String stopMode; // 'never' | 'attempts' | 'minutes' | 'matches'
  final int stopValue; // 停止條件數值

  const SearchParams({
    required this.location,
    required this.hotelCodes,
    required this.checkin,
    required this.checkout,
    required this.numPeople,
    this.numRooms = 1,
    this.smokingType = 'all',
    required this.targetPrice,
    this.intervalSec = 15,
    this.stopMode = 'never',
    this.stopValue = 100,
  });

  SearchParams copyWith({
    String? location,
    List<String>? hotelCodes,
    String? checkin,
    String? checkout,
    int? numPeople,
    int? numRooms,
    String? smokingType,
    Object? targetPrice = _unset,
    int? intervalSec,
    String? stopMode,
    int? stopValue,
  }) {
    return SearchParams(
      location: location ?? this.location,
      hotelCodes: hotelCodes ?? this.hotelCodes,
      checkin: checkin ?? this.checkin,
      checkout: checkout ?? this.checkout,
      numPeople: numPeople ?? this.numPeople,
      numRooms: numRooms ?? this.numRooms,
      smokingType: smokingType ?? this.smokingType,
      targetPrice: identical(targetPrice, _unset)
          ? this.targetPrice
          : targetPrice as int?,
      intervalSec: intervalSec ?? this.intervalSec,
      stopMode: stopMode ?? this.stopMode,
      stopValue: stopValue ?? this.stopValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'location': location,
    'hotelCodes': hotelCodes,
    'checkin': checkin,
    'checkout': checkout,
    'numPeople': numPeople,
    'numRooms': numRooms,
    'smokingType': smokingType,
    'targetPrice': targetPrice,
    'intervalSec': intervalSec,
    'stopMode': stopMode,
    'stopValue': stopValue,
  };

  factory SearchParams.fromJson(Map<String, dynamic> json) => SearchParams(
    location: json['location'] as String? ?? '',
    hotelCodes: (json['hotelCodes'] as List?)?.cast<String>() ?? [],
    checkin: json['checkin'] as String? ?? '',
    checkout: json['checkout'] as String? ?? '',
    numPeople: json['numPeople'] as int? ?? 1,
    numRooms: json['numRooms'] as int? ?? 1,
    smokingType: _normalizeSmokingType(json['smokingType'] as String?),
    targetPrice: json.containsKey('targetPrice')
        ? json['targetPrice'] as int?
        : 5000,
    intervalSec: json['intervalSec'] as int? ?? 15,
    stopMode: json['stopMode'] as String? ?? 'never',
    stopValue: json['stopValue'] as int? ?? 100,
  );
}

const _unset = Object();

String _normalizeSmokingType(String? value) {
  return switch (value) {
    'all' || 'noSmoking' || 'smoking' => value!,
    _ => 'all',
  };
}
