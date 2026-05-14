import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/settings_provider.dart';
import 'utils/app_theme.dart';
import 'ui/app_shell.dart';
import 'ui/home_page.dart';
import 'ui/panels/date_scan_panel.dart';
import 'ui/panels/settings_panel.dart';
import 'ui/panels/tasks_panel.dart';

CustomTransitionPage<void> _fadeSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (ctx, animation, secondary, child) {
      final fade = CurveTween(curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0.03, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));
      return FadeTransition(
        opacity: animation.drive(fade),
        child: SlideTransition(position: animation.drive(slide), child: child),
      );
    },
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, s) => _fadeSlidePage(s, const HomePage()),
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (_, s) => _fadeSlidePage(s, const TasksPanel()),
        ),
        GoRoute(
          path: '/scan',
          pageBuilder: (_, s) => _fadeSlidePage(s, const DateScanPanel()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (_, s) => _fadeSlidePage(s, const SettingsPanel()),
        ),
      ],
    ),
  ],
);

class ToyokoApp extends ConsumerWidget {
  const ToyokoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeStr = ref.watch(themeModeProvider);
    final localeStr = ref.watch(localeProvider);

    final themeMode = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };

    final locale = Locale(
      localeStr.contains('_') ? localeStr.split('_')[0] : localeStr,
      localeStr.contains('_') ? localeStr.split('_')[1] : null,
    );

    return MaterialApp.router(
      title: '東橫 INN 監控器',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return supported.first;
        for (final s in supported) {
          if (s.languageCode == locale.languageCode &&
              (s.countryCode == null ||
               s.countryCode == locale.countryCode)) {
            return s;
          }
        }
        return supported.first;
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
