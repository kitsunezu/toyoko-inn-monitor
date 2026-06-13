import 'dart:convert';
import 'dart:io';

const officialHotelListUrl = 'https://www.toyoko-inn.com/china/hotel_list/';
const defaultOutputPath = 'lib/data/locations.dart';

const appLocationOrder = [
  '北海道 (Hokkaido)',
  '東北 (Tohoku)',
  '東京 (Tokyo)',
  '神奈川 (Kanagawa)',
  '埼玉 (Saitama)',
  '千葉 (Chiba)',
  '茨城栃木群馬',
  '名古屋愛知 (Nagoya)',
  '靜岡 (Shizuoka)',
  '岐阜三重 (Gifu/Mie)',
  '甲信越北陸',
  '滋賀奈良 (Shiga/Nara)',
  '京都 (Kyoto)',
  '大阪 (Osaka)',
  '兵庫和歌山 (Kobe)',
  '中國地方 (Chugoku)',
  '四國 (Shikoku)',
  '福岡 (Fukuoka)',
  '佐賀長崎 (Saga/Nagasaki)',
  '熊本 (Kumamoto)',
  '大分宮崎 (Oita/Miyazaki)',
  '鹿兒島 (Kagoshima)',
  '沖繩 (Okinawa)',
  '韓國首爾 (Seoul)',
  '韓國釜山 (Busan)',
  '韓國其他 (Other Korea)',
  '日本以外',
  '其他',
];

const _prefectureToAppLocation = {
  '北海道': '北海道 (Hokkaido)',
  '青森縣': '東北 (Tohoku)',
  '岩手縣': '東北 (Tohoku)',
  '秋田縣': '東北 (Tohoku)',
  '宮城縣': '東北 (Tohoku)',
  '山形縣': '東北 (Tohoku)',
  '福島縣': '東北 (Tohoku)',
  '東京都': '東京 (Tokyo)',
  '神奈川縣': '神奈川 (Kanagawa)',
  '埼玉縣': '埼玉 (Saitama)',
  '千葉縣': '千葉 (Chiba)',
  '茨城縣': '茨城栃木群馬',
  '栃木縣': '茨城栃木群馬',
  '群馬縣': '茨城栃木群馬',
  '愛知縣': '名古屋愛知 (Nagoya)',
  '靜岡縣': '靜岡 (Shizuoka)',
  '岐阜縣': '岐阜三重 (Gifu/Mie)',
  '三重縣': '岐阜三重 (Gifu/Mie)',
  '山梨縣': '甲信越北陸',
  '長野縣': '甲信越北陸',
  '新潟縣': '甲信越北陸',
  '富山縣': '甲信越北陸',
  '石川縣': '甲信越北陸',
  '福井縣': '甲信越北陸',
  '滋賀縣': '滋賀奈良 (Shiga/Nara)',
  '奈良縣': '滋賀奈良 (Shiga/Nara)',
  '京都府': '京都 (Kyoto)',
  '大阪府': '大阪 (Osaka)',
  '兵庫縣': '兵庫和歌山 (Kobe)',
  '和歌山縣': '兵庫和歌山 (Kobe)',
  '岡山縣': '中國地方 (Chugoku)',
  '廣島縣': '中國地方 (Chugoku)',
  '鳥取縣': '中國地方 (Chugoku)',
  '島根縣': '中國地方 (Chugoku)',
  '山口縣': '中國地方 (Chugoku)',
  '香川縣': '四國 (Shikoku)',
  '愛媛縣': '四國 (Shikoku)',
  '德島縣': '四國 (Shikoku)',
  '高知縣': '四國 (Shikoku)',
  '福岡縣': '福岡 (Fukuoka)',
  '佐賀縣': '佐賀長崎 (Saga/Nagasaki)',
  '長崎縣': '佐賀長崎 (Saga/Nagasaki)',
  '熊本縣': '熊本 (Kumamoto)',
  '大分縣': '大分宮崎 (Oita/Miyazaki)',
  '宮崎縣': '大分宮崎 (Oita/Miyazaki)',
  '鹿兒島縣': '鹿兒島 (Kagoshima)',
  '沖繩縣': '沖繩 (Okinawa)',
};

Future<void> main(List<String> args) async {
  final result = await runSyncHotels(args);
  if (result != 0) exitCode = result;
}

Future<int> runSyncHotels(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.write(_usage);
    return 0;
  }

  final checkOnly = args.contains('--check');
  final inputPath = _optionValue(args, '--input');
  final outputPath = _optionValue(args, '--output') ?? defaultOutputPath;
  final url = _optionValue(args, '--url') ?? officialHotelListUrl;
  final auditJsonPath = _optionValue(args, '--audit-json');

  final html = inputPath == null
      ? await _fetch(url)
      : await File(inputPath).readAsString();
  final official = parseHotelCatalog(html, sourceUrl: url);

  final outputFile = File(outputPath);
  final existing = outputFile.existsSync()
      ? parseExistingLocations(outputFile.readAsStringSync())
      : ExistingCatalog.empty();
  final diff = diffCatalogs(existing, official);

  if (auditJsonPath != null) {
    await File(auditJsonPath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(diff.toJson(official)),
    );
  }

  stdout.writeln(diff.format(official));

  if (checkOnly) {
    return diff.hasChanges ? 1 : 0;
  }

  await outputFile.writeAsString(generateLocationsDart(official));
  stdout.writeln('Updated $outputPath with ${official.hotels.length} hotels.');
  return 0;
}

HotelCatalog parseHotelCatalog(
  String html, {
  String sourceUrl = officialHotelListUrl,
}) {
  final hotels = <HotelEntry>[];
  final seenCodes = <String>{};
  final sectionPattern = RegExp(
    r'<section\b[^>]*id="region-\d+"[^>]*>(.*?)</section>',
    dotAll: true,
  );
  final h2Pattern = RegExp(r'<h2\b[^>]*>(.*?)</h2>', dotAll: true);
  final h3Pattern = RegExp(r'<h3\b[^>]*>(.*?)</h3>', dotAll: true);
  final cardPattern = RegExp(
    r'<li\b[^>]*HotelListCard_list-item[^>]*>(.*?)</li>',
    dotAll: true,
  );

  for (final sectionMatch in sectionPattern.allMatches(html)) {
    final section = sectionMatch.group(1)!;
    final regionMatch = h2Pattern.firstMatch(section);
    if (regionMatch == null) continue;

    final region = _textFromHtml(regionMatch.group(1)!);
    final prefectureMatches = h3Pattern.allMatches(section).toList();
    for (var i = 0; i < prefectureMatches.length; i++) {
      final prefectureMatch = prefectureMatches[i];
      final prefecture = _textFromHtml(prefectureMatch.group(1)!);
      final blockEnd = i + 1 < prefectureMatches.length
          ? prefectureMatches[i + 1].start
          : section.length;
      final prefectureBlock = section.substring(prefectureMatch.end, blockEnd);

      for (final cardMatch in cardPattern.allMatches(prefectureBlock)) {
        final parsed = _parseHotelCard(
          cardMatch.group(1)!,
          region: region,
          prefecture: prefecture,
        );
        if (parsed == null) continue;
        if (!seenCodes.add(parsed.code)) {
          throw FormatException('Duplicate hotel code ${parsed.code}');
        }
        hotels.add(parsed);
      }
    }
  }

  if (hotels.length < 300) {
    throw FormatException(
      'Parsed only ${hotels.length} hotels from $sourceUrl; aborting.',
    );
  }

  return HotelCatalog(sourceUrl: sourceUrl, hotels: hotels);
}

ExistingCatalog parseExistingLocations(String source) {
  final locationBlock = _extractMapLiteral(
    source,
    'const Map<String, List<String>> kLocations',
  );
  final namesBlock = _extractMapLiteral(
    source,
    'const Map<String, String> kHotelNames',
  );
  final detailsBlock =
      source.contains('const Map<String, HotelLocationInfo> kHotelDetails')
      ? _extractMapLiteral(
          source,
          'const Map<String, HotelLocationInfo> kHotelDetails',
        )
      : null;

  final locationsByCode = <String, String>{};
  final locationEntryPattern = RegExp(
    r"'((?:\\.|[^'])*)'\s*:\s*\[(.*?)\]",
    dotAll: true,
  );
  for (final match in locationEntryPattern.allMatches(locationBlock)) {
    final location = _unescapeDartString(match.group(1)!);
    final codes = RegExp(
      r"'(\d{5})'",
    ).allMatches(match.group(2)!).map((m) => m.group(1)!).toList();
    for (final code in codes) {
      locationsByCode[code] = location;
    }
  }

  final names = <String, String>{};
  final nameEntryPattern = RegExp(r"'(\d{5})'\s*:\s*'((?:\\.|[^'])*)'");
  for (final match in nameEntryPattern.allMatches(namesBlock)) {
    names[match.group(1)!] = _unescapeDartString(match.group(2)!);
  }

  final details = <String, ExistingHotelDetails>{};
  if (detailsBlock != null) {
    final detailsEntryPattern = RegExp(
      r"'(\d{5})'\s*:\s*HotelLocationInfo\(\s*"
      r"name:\s*'((?:\\.|[^'])*)',\s*"
      r"region:\s*'((?:\\.|[^'])*)',\s*"
      r"prefecture:\s*'((?:\\.|[^'])*)',\s*"
      r"address:\s*'((?:\\.|[^'])*)',\s*"
      r"phone:\s*'((?:\\.|[^'])*)',\s*"
      r"status:\s*'((?:\\.|[^'])*)',\s*"
      r"\)",
      dotAll: true,
    );
    for (final match in detailsEntryPattern.allMatches(detailsBlock)) {
      details[match.group(1)!] = ExistingHotelDetails(
        region: _unescapeDartString(match.group(3)!),
        prefecture: _unescapeDartString(match.group(4)!),
        address: _unescapeDartString(match.group(5)!),
        phone: _unescapeDartString(match.group(6)!),
        status: _unescapeDartString(match.group(7)!),
      );
    }
  }

  return ExistingCatalog(
    names: names,
    locationsByCode: locationsByCode,
    details: details,
  );
}

CatalogDiff diffCatalogs(ExistingCatalog existing, HotelCatalog official) {
  final officialByCode = official.byCode;
  final existingCodes = existing.names.keys.toSet();
  final officialCodes = officialByCode.keys.toSet();
  final added = officialCodes.difference(existingCodes).toList()..sort();
  final removed = existingCodes.difference(officialCodes).toList()..sort();
  final renamed = <String>[];
  final moved = <String>[];
  final statusChanged = <String>[];
  final detailsChanged = <String>[];

  for (final code
      in officialCodes.intersection(existingCodes).toList()..sort()) {
    final hotel = officialByCode[code]!;
    if (existing.names[code] != hotel.name) renamed.add(code);
    if (existing.locationsByCode[code] != hotel.appLocation) moved.add(code);

    final detail = existing.details[code];
    if (detail != null) {
      if (detail.status != hotel.status) statusChanged.add(code);
      if (detail.region != hotel.region ||
          detail.prefecture != hotel.prefecture ||
          detail.address != hotel.address ||
          detail.phone != hotel.phone) {
        detailsChanged.add(code);
      }
    }
  }

  return CatalogDiff(
    addedCodes: added,
    removedCodes: removed,
    renamedCodes: renamed,
    movedCodes: moved,
    statusChangedCodes: statusChanged,
    detailsChangedCodes: detailsChanged,
  );
}

String generateLocationsDart(HotelCatalog catalog) {
  final buffer = StringBuffer()
    ..writeln('/// 東橫 INN 地點與飯店代碼對照表')
    ..writeln('/// 來源: $officialHotelListUrl')
    ..writeln(
      '/// Generated by `dart run tool/sync_hotels.dart`; do not edit by hand.',
    )
    ..writeln("class HotelLocationInfo {")
    ..writeln("  const HotelLocationInfo({")
    ..writeln("    required this.name,")
    ..writeln("    required this.region,")
    ..writeln("    required this.prefecture,")
    ..writeln("    required this.address,")
    ..writeln("    required this.phone,")
    ..writeln("    required this.status,")
    ..writeln("  });")
    ..writeln()
    ..writeln("  final String name;")
    ..writeln("  final String region;")
    ..writeln("  final String prefecture;")
    ..writeln("  final String address;")
    ..writeln("  final String phone;")
    ..writeln("  final String status;")
    ..writeln("}")
    ..writeln()
    ..writeln('const Map<String, List<String>> kLocations = {');

  final locationCodes = catalog.locationCodes;
  for (final location in appLocationOrder) {
    final codes = locationCodes[location];
    if (codes == null || codes.isEmpty) continue;
    buffer.writeln("  '${_escapeDartString(location)}': [");
    for (final chunk in _chunks(codes, 6)) {
      buffer.writeln("    ${chunk.map((code) => "'$code'").join(', ')},");
    }
    buffer.writeln('  ],');
  }

  buffer
    ..writeln('};')
    ..writeln()
    ..writeln('const Map<String, String> kHotelNames = {');

  for (final hotel in catalog.hotelsInAppOrder) {
    buffer.writeln("  '${hotel.code}': '${_escapeDartString(hotel.name)}',");
  }

  buffer
    ..writeln('};')
    ..writeln()
    ..writeln('const Map<String, HotelLocationInfo> kHotelDetails = {');

  for (final hotel in catalog.hotelsInAppOrder) {
    buffer
      ..writeln("  '${hotel.code}': HotelLocationInfo(")
      ..writeln("    name: '${_escapeDartString(hotel.name)}',")
      ..writeln("    region: '${_escapeDartString(hotel.region)}',")
      ..writeln("    prefecture: '${_escapeDartString(hotel.prefecture)}',")
      ..writeln("    address: '${_escapeDartString(hotel.address)}',")
      ..writeln("    phone: '${_escapeDartString(hotel.phone)}',")
      ..writeln("    status: '${_escapeDartString(hotel.status)}',")
      ..writeln('  ),');
  }

  buffer.writeln('};');
  return buffer.toString();
}

class HotelCatalog {
  const HotelCatalog({required this.sourceUrl, required this.hotels});

  final String sourceUrl;
  final List<HotelEntry> hotels;

  Map<String, HotelEntry> get byCode => {
    for (final hotel in hotels) hotel.code: hotel,
  };

  Map<String, List<String>> get locationCodes {
    final result = <String, List<String>>{
      for (final location in appLocationOrder) location: <String>[],
    };
    for (final hotel in hotels) {
      result.putIfAbsent(hotel.appLocation, () => <String>[]).add(hotel.code);
    }
    result.removeWhere((_, codes) => codes.isEmpty);
    return result;
  }

  List<HotelEntry> get hotelsInAppOrder {
    final byLocation = <String, List<HotelEntry>>{};
    for (final hotel in hotels) {
      byLocation
          .putIfAbsent(hotel.appLocation, () => <HotelEntry>[])
          .add(hotel);
    }
    return [for (final location in appLocationOrder) ...?byLocation[location]];
  }

  List<String> get unmatchedCodes => [
    for (final hotel in hotels)
      if (hotel.appLocation == '其他') hotel.code,
  ];
}

class HotelEntry {
  const HotelEntry({
    required this.code,
    required this.name,
    required this.region,
    required this.prefecture,
    required this.appLocation,
    required this.address,
    required this.phone,
    required this.status,
  });

  final String code;
  final String name;
  final String region;
  final String prefecture;
  final String appLocation;
  final String address;
  final String phone;
  final String status;

  Map<String, Object> toJson() => {
    'code': code,
    'name': name,
    'region': region,
    'prefecture': prefecture,
    'appLocation': appLocation,
    'address': address,
    'phone': phone,
    'status': status,
  };
}

class ExistingCatalog {
  const ExistingCatalog({
    required this.names,
    required this.locationsByCode,
    required this.details,
  });

  factory ExistingCatalog.empty() =>
      const ExistingCatalog(names: {}, locationsByCode: {}, details: {});

  final Map<String, String> names;
  final Map<String, String> locationsByCode;
  final Map<String, ExistingHotelDetails> details;
}

class ExistingHotelDetails {
  const ExistingHotelDetails({
    required this.region,
    required this.prefecture,
    required this.address,
    required this.phone,
    required this.status,
  });

  final String region;
  final String prefecture;
  final String address;
  final String phone;
  final String status;
}

class CatalogDiff {
  const CatalogDiff({
    required this.addedCodes,
    required this.removedCodes,
    required this.renamedCodes,
    required this.movedCodes,
    required this.statusChangedCodes,
    required this.detailsChangedCodes,
  });

  final List<String> addedCodes;
  final List<String> removedCodes;
  final List<String> renamedCodes;
  final List<String> movedCodes;
  final List<String> statusChangedCodes;
  final List<String> detailsChangedCodes;

  bool get hasChanges =>
      addedCodes.isNotEmpty ||
      removedCodes.isNotEmpty ||
      renamedCodes.isNotEmpty ||
      movedCodes.isNotEmpty ||
      statusChangedCodes.isNotEmpty ||
      detailsChangedCodes.isNotEmpty;

  String format(HotelCatalog catalog) {
    if (!hasChanges) {
      return 'Hotel catalog is up to date (${catalog.hotels.length} hotels).';
    }

    final buffer = StringBuffer()
      ..writeln('Hotel catalog differs from ${catalog.sourceUrl}.');
    _writeCodeList(buffer, 'Added', addedCodes, catalog);
    _writeCodeList(buffer, 'Removed', removedCodes, catalog);
    _writeCodeList(buffer, 'Renamed', renamedCodes, catalog);
    _writeCodeList(buffer, 'Moved', movedCodes, catalog);
    _writeCodeList(buffer, 'Status changed', statusChangedCodes, catalog);
    _writeCodeList(buffer, 'Details changed', detailsChangedCodes, catalog);
    _writeCodeList(
      buffer,
      'Unmatched location',
      catalog.unmatchedCodes,
      catalog,
    );
    return buffer.toString().trimRight();
  }

  Map<String, Object> toJson(HotelCatalog catalog) {
    final byCode = catalog.byCode;
    Object values(List<String> codes) => [
      for (final code in codes) byCode[code]?.toJson() ?? {'code': code},
    ];
    return {
      'sourceUrl': catalog.sourceUrl,
      'hotelCount': catalog.hotels.length,
      'hasChanges': hasChanges,
      'added': values(addedCodes),
      'removed': values(removedCodes),
      'renamed': values(renamedCodes),
      'moved': values(movedCodes),
      'statusChanged': values(statusChangedCodes),
      'detailsChanged': values(detailsChangedCodes),
      'unmatchedLocation': values(catalog.unmatchedCodes),
    };
  }
}

HotelEntry? _parseHotelCard(
  String card, {
  required String region,
  required String prefecture,
}) {
  final hotelLinkPattern = RegExp(
    r'<a\b[^>]*href="(?:/[a-zA-Z-]+)?/search/detail/(\d{5})/?"[^>]*>(.*?)</a>',
    dotAll: true,
  );
  final linkMatch = hotelLinkPattern.firstMatch(card);
  if (linkMatch == null) return null;

  final code = linkMatch.group(1)!;
  final name = _textFromHtml(
    linkMatch.group(2)!,
  ).replaceFirst(RegExp(r'^(東[橫横]|东横)INN\s*'), '').trim();
  final paragraphs = RegExp(r'<p\b[^>]*>(.*?)</p>', dotAll: true)
      .allMatches(card)
      .map((m) => _textFromHtml(m.group(1)!))
      .where((text) => text.isNotEmpty)
      .toList();
  final tags =
      RegExp(
            r'<div\b[^>]*class="[^"]*Tag_[^"]*"[^>]*>(.*?)</div>',
            dotAll: true,
          )
          .allMatches(card)
          .map((m) => _textFromHtml(m.group(1)!))
          .where((text) => text.isNotEmpty)
          .toList();

  return HotelEntry(
    code: code,
    name: name,
    region: region,
    prefecture: prefecture,
    appLocation: _appLocationFor(region, prefecture, name),
    address: paragraphs.isEmpty ? '' : paragraphs.first,
    phone: paragraphs.length < 2 ? '' : paragraphs.last,
    status: tags.join(' / '),
  );
}

String _appLocationFor(String region, String prefecture, String name) {
  if (prefecture == '韓國') {
    if (name.contains('首爾')) return '韓國首爾 (Seoul)';
    if (name.contains('釜山')) return '韓國釜山 (Busan)';
    return '韓國其他 (Other Korea)';
  }
  if (region == '日本以外') return '日本以外';
  return _prefectureToAppLocation[prefecture] ?? '其他';
}

Future<String> _fetch(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers
      ..set(HttpHeaders.userAgentHeader, 'toyoko-inn-monitor catalog sync')
      ..set(HttpHeaders.acceptHeader, 'text/html,application/xhtml+xml');
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
    }
    final bytes = await response.expand((chunk) => chunk).toList();
    return utf8.decode(bytes);
  } finally {
    client.close(force: true);
  }
}

String? _optionValue(List<String> args, String name) {
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == name && i + 1 < args.length) return args[i + 1];
    if (arg.startsWith('$name=')) return arg.substring(name.length + 1);
  }
  return null;
}

String _textFromHtml(String html) {
  final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
  return _decodeHtmlEntities(
    withoutTags,
  ).replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _decodeHtmlEntities(String value) {
  return value.replaceAllMapped(RegExp(r'&(#x?[0-9a-fA-F]+|\w+);'), (match) {
    final entity = match.group(1)!;
    if (entity.startsWith('#x') || entity.startsWith('#X')) {
      final codePoint = int.tryParse(entity.substring(2), radix: 16);
      return codePoint == null
          ? match.group(0)!
          : String.fromCharCode(codePoint);
    }
    if (entity.startsWith('#')) {
      final codePoint = int.tryParse(entity.substring(1));
      return codePoint == null
          ? match.group(0)!
          : String.fromCharCode(codePoint);
    }
    return switch (entity) {
      'amp' => '&',
      'apos' => "'",
      'gt' => '>',
      'lt' => '<',
      'nbsp' => ' ',
      'quot' => '"',
      _ => match.group(0)!,
    };
  });
}

String _extractMapLiteral(String source, String declaration) {
  final declarationIndex = source.indexOf(declaration);
  if (declarationIndex < 0) {
    throw FormatException('Missing declaration: $declaration');
  }
  final openIndex = source.indexOf('{', declarationIndex);
  if (openIndex < 0) {
    throw FormatException('Missing map literal for: $declaration');
  }

  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var i = openIndex; i < source.length; i++) {
    final char = source[i];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char == '\\') {
        escaped = true;
      } else if (char == "'") {
        inString = false;
      }
      continue;
    }

    if (char == "'") {
      inString = true;
    } else if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
      if (depth == 0) {
        return source.substring(openIndex, i + 1);
      }
    }
  }
  throw FormatException('Unclosed map literal for: $declaration');
}

String _escapeDartString(String value) {
  return value
      .replaceAll('\\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\r', r'\r')
      .replaceAll('\n', r'\n');
}

String _unescapeDartString(String value) {
  final buffer = StringBuffer();
  var escaped = false;
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    if (!escaped) {
      if (char == '\\') {
        escaped = true;
      } else {
        buffer.write(char);
      }
      continue;
    }

    buffer.write(switch (char) {
      'n' => '\n',
      'r' => '\r',
      't' => '\t',
      _ => char,
    });
    escaped = false;
  }
  if (escaped) buffer.write('\\');
  return buffer.toString();
}

Iterable<List<T>> _chunks<T>(List<T> values, int size) sync* {
  for (var i = 0; i < values.length; i += size) {
    yield values.sublist(
      i,
      i + size > values.length ? values.length : i + size,
    );
  }
}

void _writeCodeList(
  StringBuffer buffer,
  String label,
  List<String> codes,
  HotelCatalog catalog,
) {
  if (codes.isEmpty) return;
  final byCode = catalog.byCode;
  buffer.writeln('$label (${codes.length}):');
  for (final code in codes) {
    final hotel = byCode[code];
    final name = hotel == null ? '' : ' ${hotel.name}';
    final location = hotel == null ? '' : ' [${hotel.appLocation}]';
    buffer.writeln('  - $code$name$location');
  }
}

const _usage = '''
Usage:
  dart run tool/sync_hotels.dart [--check] [--input file] [--output file] [--audit-json file]

Options:
  --check             Compare the generated catalog with lib/data/locations.dart.
  --input <file>      Parse a saved official hotel-list HTML file instead of fetching.
  --output <file>     Output Dart catalog path. Defaults to lib/data/locations.dart.
  --url <url>         Official hotel-list URL. Defaults to the Traditional Chinese page.
  --audit-json <file> Write diff data for optional RAG/LangChain review tooling.
''';
