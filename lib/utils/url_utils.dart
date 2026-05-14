/// 生成東橫 INN 訂房 URL
String buildBookingUrl({
  required String hotelCode,
  required String checkin,
  required String checkout,
  int rooms = 1,
  int people = 2,
  String smokingType = 'noSmoking',
}) {
  return 'https://www.toyoko-inn.com/china/search/result/room_plan/'
      '?hotel=$hotelCode'
      '&start=$checkin'
      '&end=$checkout'
      '&room=$rooms'
      '&people=$people'
      '&smoking=$smokingType'
      '&tab=roomType'
      '&sort=recommend';
}
