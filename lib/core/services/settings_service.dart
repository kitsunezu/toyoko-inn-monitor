import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _prefix = 'toyoko_';

class SettingsService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Getters / Setters ──

  String get location => _get('location', '東京 (Tokyo)');
  Future<void> setLocation(String v) => _set('location', v);

  String get checkin => _get('checkin', _defaultCheckin());
  Future<void> setCheckin(String v) => _set('checkin', v);

  int get nights => _getInt('nights', 1);
  Future<void> setNights(int v) => _setInt('nights', v);

  int get numPeople => _getInt('num_people', 2);
  Future<void> setNumPeople(int v) => _setInt('num_people', v);

  int get numRooms => _getInt('num_rooms', 1);
  Future<void> setNumRooms(int v) => _setInt('num_rooms', v);

  String get smokingType => _get('smoking_type', 'noSmoking');
  Future<void> setSmokingType(String v) => _set('smoking_type', v);

  int get targetPrice => _getInt('target_price', 5000);
  Future<void> setTargetPrice(int v) => _setInt('target_price', v);

  int get intervalSec => _getInt('interval_sec', 15);
  Future<void> setIntervalSec(int v) => _setInt('interval_sec', v);

  String get stopMode => _get('stop_mode', 'never');
  Future<void> setStopMode(String v) => _set('stop_mode', v);

  int get stopValue => _getInt('stop_value', 100);
  Future<void> setStopValue(int v) => _setInt('stop_value', v);

  /// 找到符合目標價時自動開啟網頁
  bool get autoOpenUrl => _getBool('auto_open_url', false);
  Future<void> setAutoOpenUrl(bool v) => _setBool('auto_open_url', v);

  /// 找到符合目標價時顯示桌面通知
  bool get desktopNotification => _getBool('desktop_notification', true);
  Future<void> setDesktopNotification(bool v) => _setBool('desktop_notification', v);

  /// 'dark' | 'light' | 'system'
  String get themeMode => _get('theme_mode', 'dark');
  Future<void> setThemeMode(String v) => _set('theme_mode', v);

  /// 'zh_TW' | 'ja' | 'en'
  String get locale => _get('locale', 'zh_TW');
  Future<void> setLocale(String v) => _set('locale', v);

  List<String> get selectedHotels {
    final raw = _prefs.getString('${_prefix}selected_hotels');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<String>();
  }

  Future<void> setSelectedHotels(List<String> codes) async {
    await _prefs.setString(
      '${_prefix}selected_hotels',
      jsonEncode(codes),
    );
  }

  // ── Private helpers ──

  String _get(String key, String defaultValue) =>
      _prefs.getString('$_prefix$key') ?? defaultValue;

  Future<void> _set(String key, String value) =>
      _prefs.setString('$_prefix$key', value);

  int _getInt(String key, int defaultValue) =>
      _prefs.getInt('$_prefix$key') ?? defaultValue;

  Future<void> _setInt(String key, int value) =>
      _prefs.setInt('$_prefix$key', value);

  bool _getBool(String key, bool defaultValue) =>
      _prefs.getBool('$_prefix$key') ?? defaultValue;

  Future<void> _setBool(String key, bool value) =>
      _prefs.setBool('$_prefix$key', value);

  static String _defaultCheckin() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return '${tomorrow.year}-'
        '${tomorrow.month.toString().padLeft(2, '0')}-'
        '${tomorrow.day.toString().padLeft(2, '0')}';
  }
}
