import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await localNotifier.setup(
        appName: '東橫 INN 監控器',
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
      _initialized = true;
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.startsWith('http')) {
      launchUrl(Uri.parse(payload));
    }
  }

  Future<void> notifyMatches({
    required List<({String name, int price, String url})> matches,
  }) async {
    if (!_initialized || matches.isEmpty) return;

    String fmtPrice(int p) => '¥${p.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}';

    final count = matches.length;
    final title = count == 1
        ? '找到了！${matches.first.name}'
        : '找到了！$count 間飯店符合目標';
    final body =
        matches.map((m) => '${m.name}  ${fmtPrice(m.price)}').join('\n');
    final firstUrl = matches.first.url;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final notification = LocalNotification(
        identifier: 'match_batch',
        title: title,
        body: body,
      );
      notification.onClick = () => launchUrl(
        Uri.parse(firstUrl),
        mode: LaunchMode.externalApplication,
      );
      await notification.show();
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'match_channel',
        '符合目標通知',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    await _plugin.show(1, title, body, details, payload: firstUrl);
  }

  Future<void> notifyStopped(String reason) async {
    if (!_initialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final notification = LocalNotification(
        identifier: 'stopped',
        title: '監控已停止',
        body: reason,
      );
      await notification.show();
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'status_channel',
        '監控狀態',
        importance: Importance.low,
      ),
      iOS: DarwinNotificationDetails(presentAlert: false, presentSound: false),
    );

    await _plugin.show(2, '監控已停止', reason, details);
  }
}
