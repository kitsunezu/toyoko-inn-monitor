import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/services/update_service.dart';
import '../core/constants.dart';

final updateServiceProvider = Provider<UpdateService>((_) => UpdateService());

/// Async provider that resolves the current app version string (e.g. "1.0.0").
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// Holds the update-check result; starts as [UpdateInfo.idle].
final updateInfoProvider = StateProvider<UpdateInfo>((_) => UpdateInfo.idle);

/// Triggers an update check and updates [updateInfoProvider].
/// Returns the [UpdateInfo] after the check completes.
Future<UpdateInfo> checkForUpdate(WidgetRef ref) async {
  ref.read(updateInfoProvider.notifier).state = UpdateInfo.checking;

  final service = ref.read(updateServiceProvider);

  final current = await _currentAppVersion(ref);
  if (current == null) {
    final info = UpdateInfo.failed;
    ref.read(updateInfoProvider.notifier).state = info;
    return info;
  }

  final tag = await service.fetchLatestTag();
  if (tag == null) {
    final info = UpdateInfo.failed;
    ref.read(updateInfoProvider.notifier).state = info;
    return info;
  }

  final info = service.isNewer(tag, current)
      ? UpdateInfo(UpdateStatus.available, latestVersion: tag)
      : UpdateInfo.latest;

  ref.read(updateInfoProvider.notifier).state = info;
  return info;
}

/// Convenience: URL to open for downloading the update.
String get updateDownloadUrl => AppConstants.githubReleasesPageUrl;

Future<String?> _currentAppVersion(WidgetRef ref) async {
  try {
    return await ref.read(appVersionProvider.future);
  } catch (_) {
    return null;
  }
}
