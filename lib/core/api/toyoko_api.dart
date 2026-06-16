import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/hotel_price.dart';
import '../../utils/date_utils.dart';
import '../../utils/url_utils.dart';

const _apiUrl =
    'https://www.toyoko-inn.com/api/trpc/hotels.availabilities.prices';

const _headers = {
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/125.0.0.0 Safari/537.36',
  'Accept': 'application/json',
  'Referer': 'https://www.toyoko-inn.com/',
};

class ToyokoApi {
  final Dio _dio;

  ToyokoApi()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: _headers,
        ),
      );

  /// 查詢多間飯店的房價
  Future<List<HotelPrice>> fetchPrices({
    required List<String> hotelCodes,
    required String checkinDate,
    required String checkoutDate,
    required int numPeople,
    int numRooms = 1,
    String smokingType = 'all',
    Map<String, String> hotelNames = const {},
  }) async {
    final inputData = {
      '0': {
        'json': {
          'hotelCodes': hotelCodes,
          'checkinDate': toApiDate(checkinDate),
          'checkoutDate': toApiDate(checkoutDate),
          'numberOfPeople': numPeople,
          'numberOfRoom': numRooms,
          'smokingType': smokingType,
        },
        'meta': {
          'values': {
            'checkinDate': ['Date'],
            'checkoutDate': ['Date'],
          },
        },
      },
    };

    final response = await _dio.get(
      _apiUrl,
      queryParameters: {'batch': '1', 'input': jsonEncode(inputData)},
    );

    final rawList = response.data as List;
    final prices =
        rawList[0]['result']['data']['json']['prices'] as Map<String, dynamic>;

    final hotels = {
      for (final e in prices.entries)
        e.key: HotelPrice.fromJson(
          e.key,
          e.value as Map<String, dynamic>,
          hotelNames[e.key] ?? e.key,
        ),
    };

    final memberPrices = await Future.wait(
      hotelCodes.map(
        (code) => _fetchMemberRoomPlanPrice(
          code: code,
          name: hotelNames[code] ?? code,
          checkinDate: checkinDate,
          checkoutDate: checkoutDate,
          numPeople: numPeople,
          numRooms: numRooms,
          smokingType: smokingType,
        ),
      ),
    );

    for (final memberPrice in memberPrices) {
      if (memberPrice != null) {
        hotels[memberPrice.code] = memberPrice;
      }
    }

    return hotelCodes.map((code) {
      return hotels[code] ??
          HotelPrice(
            code: code,
            name: hotelNames[code] ?? code,
            price: 0,
            vacant: false,
            maintenance: false,
          );
    }).toList();
  }

  Future<HotelPrice?> _fetchMemberRoomPlanPrice({
    required String code,
    required String name,
    required String checkinDate,
    required String checkoutDate,
    required int numPeople,
    required int numRooms,
    required String smokingType,
  }) async {
    final url = buildBookingUrl(
      hotelCode: code,
      checkin: checkinDate,
      checkout: checkoutDate,
      rooms: numRooms,
      people: numPeople,
      smokingType: smokingType,
    );

    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: const {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );
      final html = response.data;
      if (html == null) return null;
      return parseMemberRoomPlanPrice(
        code: code,
        name: name,
        html: html,
        smokingType: smokingType,
      );
    } catch (_) {
      return null;
    }
  }
}

HotelPrice? parseMemberRoomPlanPrice({
  required String code,
  required String name,
  required String html,
  required String smokingType,
}) {
  final match = RegExp(
    r'<script id="__NEXT_DATA__" type="application/json">(.*?)</script>',
    dotAll: true,
  ).firstMatch(html);
  if (match == null) return null;

  final dynamic decoded;
  try {
    decoded = jsonDecode(match.group(1)!);
  } catch (_) {
    return null;
  }

  final root = _asMap(decoded);
  final props = _asMap(root['props']);
  final pageProps = _asMap(props['pageProps']);
  final planResponse = _asMap(pageProps['planResponse']);
  final roomTypes = planResponse['roomTypeList'];
  if (roomTypes is! List) return null;

  int? lowestMemberPrice;
  for (final roomType in roomTypes) {
    final room = _asMap(roomType);
    final specs = _asMap(room['specs']);
    final isSmoking = specs['isSmoking'] as bool?;
    if (!_matchesSmokingType(isSmoking, smokingType)) continue;

    final plans = room['plans'];
    if (plans is! List) continue;

    for (final planValue in plans) {
      final plan = _asMap(planValue);
      final price = _asMap(plan['price']);
      final vacant = _asMap(plan['vacant']);
      final memberPrice = (price['membershipPrice'] as num?)?.toInt();
      final memberVacant = (vacant['membershipVacantRoom'] as num?)?.toInt();
      if (memberPrice == null || memberVacant == null) continue;
      if (memberVacant <= 0 || memberPrice <= 0) continue;
      if (lowestMemberPrice == null || memberPrice < lowestMemberPrice) {
        lowestMemberPrice = memberPrice;
      }
    }
  }

  if (lowestMemberPrice == null) return null;
  return HotelPrice(
    code: code,
    name: name,
    price: lowestMemberPrice,
    vacant: true,
    maintenance: false,
  );
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return const {};
}

bool _matchesSmokingType(bool? isSmoking, String smokingType) {
  return switch (smokingType) {
    'smoking' => isSmoking == true,
    'noSmoking' => isSmoking == false,
    _ => true,
  };
}
