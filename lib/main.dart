import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'db/app_database.dart';
import 'core/services/settings_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/history_service.dart';
import 'providers/settings_provider.dart';
import 'providers/poller_provider.dart';
import 'providers/tasks_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1360, 820),
      minimumSize: Size(1060, 680),
      title: '東橫 INN 監控器',
      center: true,
      backgroundColor: Color(0xFF0F141B),
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final db = AppDatabase();
  final settings = SettingsService();
  await settings.init();
  final notif = NotificationService();
  await notif.init();
  final history = HistoryService(db);

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(notif),
        historyServiceProvider.overrideWithValue(history),
        dbProvider.overrideWithValue(db),
      ],
      child: const ToyokoApp(),
    ),
  );
}
