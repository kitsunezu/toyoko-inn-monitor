import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/data/locations.dart';

import '../tool/sync_hotels.dart';

void main() {
  test('parses official hotel cards from fixture HTML', () {
    final catalog = parseHotelCatalog(_fixtureHtml);

    expect(catalog.hotels.length, 301);

    final opening = catalog.byCode['00374']!;
    expect(opening.name, '吳站');
    expect(opening.region, '中國、四國');
    expect(opening.prefecture, '廣島縣');
    expect(opening.appLocation, '中國地方 (Chugoku)');
    expect(opening.address, '3-33 Takara-machi, Kure City, Hiroshima');
    expect(opening.phone, '0823-23-1045');
    expect(opening.status, '2026.07.02 計畫開業');

    final renovation = catalog.byCode['00011']!;
    expect(renovation.status, '2025.12.11 翻新');

    final overseas = catalog.byCode['00208']!;
    expect(overseas.name, '首爾東大門1號店');
    expect(overseas.region, '日本以外');
    expect(overseas.prefecture, '韓國');
    expect(overseas.appLocation, '韓國首爾 (Seoul)');
  });

  test('generated catalog has stable public invariants', () {
    final allCodes = <String>{};

    for (final entry in kLocations.entries) {
      expect(
        entry.value,
        isNotEmpty,
        reason: '${entry.key} should not be empty',
      );
      for (final code in entry.value) {
        expect(code, matches(RegExp(r'^\d{5}$')));
        expect(kHotelNames, contains(code));
        expect(kHotelDetails, contains(code));
        expect(allCodes.add(code), isTrue, reason: '$code is duplicated');
      }
    }

    expect(kHotelNames.keys.toSet(), allCodes);
    expect(kHotelDetails.keys.toSet(), allCodes);
    expect(allCodes.length, greaterThanOrEqualTo(300));
  });
}

String get _fixtureHtml {
  final repeatedCards = List.generate(298, (i) {
    final code = (10000 + i).toString().padLeft(5, '0');
    return '''
<li class="HotelListCard_list-item__oci_B">
  <div class="HotelListCard_info-block___uH88">
    <a href="/china/search/detail/$code/">東橫INN 測試飯店$code</a>
    <div class="HotelListCard_address-block__haTAs">
      <p>Test address $code</p>
      <p class="HotelListCard_tel__IScyZ">000-$code</p>
    </div>
  </div>
</li>
''';
  }).join();

  return '''
<section id="region-2" class="hotel_list_region-block__N_lmj">
  <h2 class="hotel_list_name__ACv_j">東北</h2>
  <div class="hotel_list_prefecture-block__urBWr">
    <h3 class="hotel_list_name__ACv_j">宮城縣</h3>
    <ul class="hotel_list_list__I0kpv">
      <li class="HotelListCard_list-item__oci_B">
        <div class="HotelListCard_info-block___uH88">
          <div class="HotelListCard_tag__DRzcD">
            <div class="Tag_tag-component__cGANu">2025.12.11 翻新</div>
          </div>
          <a href="/china/search/detail/00011/">東橫INN 仙台東口1號店</a>
          <div class="HotelListCard_address-block__haTAs">
            <p>3-4-31 Tsutsujigaoka</p>
            <p class="HotelListCard_tel__IScyZ">022-256-1045</p>
          </div>
        </div>
      </li>
    </ul>
  </div>
</section>
<section id="region-7" class="hotel_list_region-block__N_lmj">
  <h2 class="hotel_list_name__ACv_j">中國、四國</h2>
  <div class="hotel_list_prefecture-block__urBWr">
    <h3 class="hotel_list_name__ACv_j">廣島縣</h3>
    <ul class="hotel_list_list__I0kpv">
      <li class="HotelListCard_list-item__oci_B">
        <div class="HotelListCard_info-block___uH88">
          <div class="HotelListCard_tag__DRzcD">
            <div class="Tag_tag-component__cGANu Tag_-gold__1QFRt">
              2026.07.02 計畫開業
            </div>
          </div>
          <a href="/china/search/detail/00374/">東橫INN 吳站</a>
          <div class="HotelListCard_address-block__haTAs">
            <p>3-33 Takara-machi, Kure City, Hiroshima</p>
            <p class="HotelListCard_tel__IScyZ">0823-23-1045</p>
          </div>
        </div>
      </li>
      $repeatedCards
    </ul>
  </div>
</section>
<section id="region-8" class="hotel_list_region-block__N_lmj">
  <h2 class="hotel_list_name__ACv_j">日本以外</h2>
  <div class="hotel_list_prefecture-block__urBWr">
    <h3 class="hotel_list_name__ACv_j">韓國</h3>
    <ul class="hotel_list_list__I0kpv">
      <li class="HotelListCard_list-item__oci_B">
        <div class="HotelListCard_info-block___uH88">
          <a href="/search/detail/00208" target="_blank">東橫INN 首爾東大門1號店</a>
          <div class="HotelListCard_address-block__haTAs">
            <p>337, Toegye-ro, Jung-gu, Seoul</p>
            <p class="HotelListCard_tel__IScyZ">+82-(0)2-2138-1045</p>
          </div>
        </div>
      </li>
    </ul>
  </div>
</section>
''';
}
