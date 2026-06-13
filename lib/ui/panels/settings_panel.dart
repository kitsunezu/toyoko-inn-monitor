import 'package:flutter/material.dart';
import 'package:toyoko_inn_monitor/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/settings_provider.dart';
import '../../providers/update_provider.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/update_service.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsServiceProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final autoOpenUrl = ref.watch(autoOpenUrlProvider);
    final desktopNotif = ref.watch(desktopNotificationProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.pageSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme
          _SectionHeader(l.sectionAppearance),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l.themeDark),
                  leading: Radio<String>(
                    value: 'dark',
                    groupValue: themeMode,
                    onChanged: (v) => _setTheme(ref, settings, v!),
                  ),
                  onTap: () => _setTheme(ref, settings, 'dark'),
                ),
                ListTile(
                  title: Text(l.themeLight),
                  leading: Radio<String>(
                    value: 'light',
                    groupValue: themeMode,
                    onChanged: (v) => _setTheme(ref, settings, v!),
                  ),
                  onTap: () => _setTheme(ref, settings, 'light'),
                ),
                ListTile(
                  title: Text(l.themeSystem),
                  leading: Radio<String>(
                    value: 'system',
                    groupValue: themeMode,
                    onChanged: (v) => _setTheme(ref, settings, v!),
                  ),
                  onTap: () => _setTheme(ref, settings, 'system'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Language
          _SectionHeader(l.sectionLanguage),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l.langZhTW),
                  leading: Radio<String>(
                    value: 'zh_TW',
                    groupValue: locale,
                    onChanged: (v) => _setLocale(ref, settings, v!),
                  ),
                  onTap: () => _setLocale(ref, settings, 'zh_TW'),
                ),
                ListTile(
                  title: Text(l.langJa),
                  leading: Radio<String>(
                    value: 'ja',
                    groupValue: locale,
                    onChanged: (v) => _setLocale(ref, settings, v!),
                  ),
                  onTap: () => _setLocale(ref, settings, 'ja'),
                ),
                ListTile(
                  title: Text(l.langEn),
                  leading: Radio<String>(
                    value: 'en',
                    groupValue: locale,
                    onChanged: (v) => _setLocale(ref, settings, v!),
                  ),
                  onTap: () => _setLocale(ref, settings, 'en'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Match actions
          _SectionHeader(l.sectionMatchActions),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l.autoOpenUrlTitle),
                  subtitle: Text(l.autoOpenUrlDesc),
                  value: autoOpenUrl,
                  onChanged: (v) {
                    settings.setAutoOpenUrl(v);
                    ref.read(autoOpenUrlProvider.notifier).state = v;
                  },
                ),
                SwitchListTile(
                  title: Text(l.desktopNotifTitle),
                  subtitle: Text(l.desktopNotifDesc),
                  value: desktopNotif,
                  onChanged: (v) {
                    settings.setDesktopNotification(v);
                    ref.read(desktopNotificationProvider.notifier).state = v;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // About
          _SectionHeader(l.sectionAbout),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l.aboutAppTitle),
                  subtitle: Text(l.aboutAppSubtitle),
                ),
                const Divider(height: 1),
                _UpdateTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setTheme(WidgetRef ref, SettingsService settings, String mode) {
    settings.setThemeMode(mode);
    ref.read(themeModeProvider.notifier).state = mode;
  }

  void _setLocale(WidgetRef ref, SettingsService settings, String loc) {
    settings.setLocale(loc);
    ref.read(localeProvider.notifier).state = loc;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ── Update check tile ─────────────────────────────────────────

class _UpdateTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final versionAsync = ref.watch(appVersionProvider);
    final updateInfo = ref.watch(updateInfoProvider);

    final versionLabel = versionAsync.when(
      data: (v) => 'v$v',
      loading: () => '...',
      error: (error, stackTrace) => '',
    );

    Widget? trailing;
    String? statusText;

    switch (updateInfo.status) {
      case UpdateStatus.idle:
        trailing = FilledButton.tonal(
          onPressed: () => checkForUpdate(ref),
          child: Text(l.btnCheckUpdate),
        );
      case UpdateStatus.checking:
        statusText = l.updateChecking;
        trailing = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UpdateStatus.latest:
        statusText = l.updateLatest;
      case UpdateStatus.available:
        statusText = updateInfo.installerUrl == null
            ? l.updateInstallerMissing
            : l.updateAvailable(updateInfo.latestVersion ?? '');
        trailing = FilledButton(
          onPressed: updateInfo.installerUrl == null
              ? () => launchUrl(
                  Uri.parse(updateDownloadUrl),
                  mode: LaunchMode.externalApplication,
                )
              : () => downloadAndLaunchUpdate(ref),
          child: Text(l.btnDownloadUpdate),
        );
      case UpdateStatus.downloading:
        statusText = l.updateDownloading;
        trailing = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UpdateStatus.launchingInstaller:
        statusText = l.updateLaunchingInstaller;
        trailing = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UpdateStatus.failed:
        statusText = l.updateCheckFailed;
        trailing = FilledButton.tonal(
          onPressed: () => checkForUpdate(ref),
          child: Text(l.btnCheckUpdate),
        );
    }

    return ListTile(
      leading: const Icon(Icons.system_update_alt_outlined),
      title: Text('${l.currentVersion}: $versionLabel'),
      subtitle: statusText != null ? Text(statusText) : null,
      trailing: trailing,
    );
  }
}
