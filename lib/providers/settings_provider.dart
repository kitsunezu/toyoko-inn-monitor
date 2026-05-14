import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// 主題模式：'dark' | 'light' | 'system'
final themeModeProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return settings.themeMode;
});

/// 語系：'zh_TW' | 'ja' | 'en'
final localeProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return settings.locale;
});

/// 找到符合目標價時自動開啟網頁
final autoOpenUrlProvider = StateProvider<bool>((ref) {
  return ref.watch(settingsServiceProvider).autoOpenUrl;
});

/// 找到符合目標價時顯示桌面通知
final desktopNotificationProvider = StateProvider<bool>((ref) {
  return ref.watch(settingsServiceProvider).desktopNotification;
});
