import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/hotel_price.dart';
import '../../utils/date_utils.dart';

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
    String smokingType = 'noSmoking',
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

    return prices.entries.map((e) {
      final code = e.key;
      final info = e.value as Map<String, dynamic>;
      return HotelPrice.fromJson(code, info, hotelNames[code] ?? code);
    }).toList();
  }
}
