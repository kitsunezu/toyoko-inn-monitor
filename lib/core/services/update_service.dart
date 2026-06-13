import 'package:dio/dio.dart';
import '../constants.dart';

enum UpdateStatus { idle, checking, latest, available, failed }

class UpdateInfo {
  final UpdateStatus status;
  final String? latestVersion;

  const UpdateInfo(this.status, {this.latestVersion});

  static const idle = UpdateInfo(UpdateStatus.idle);
  static const checking = UpdateInfo(UpdateStatus.checking);
  static const latest = UpdateInfo(UpdateStatus.latest);
  static const failed = UpdateInfo(UpdateStatus.failed);
}

class UpdateService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/vnd.github+json',
        'User-Agent': '${AppConstants.githubOwner}-${AppConstants.githubRepo}',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ),
  );

  /// Returns the latest release tag from GitHub (e.g. "v1.2.0"),
  /// or null if the request fails.
  Future<String?> fetchLatestTag() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        AppConstants.githubReleasesApiUrl,
      );
      final tag = resp.data?['tag_name'] as String?;
      return tag;
    } catch (_) {
      return null;
    }
  }

  /// Compares [current] (e.g. "1.0.0") with GitHub release tag
  /// (e.g. "v1.1.0").  Returns true when a newer version is available.
  bool isNewer(String latestTag, String current) {
    return _parseVersion(latestTag) > _parseVersion(current);
  }

  int _parseVersion(String v) {
    final versionCore = v
        .trim()
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')
        .first
        .split('-')
        .first;
    final parts = versionCore
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts[0] * 1000000 + parts[1] * 1000 + parts[2];
  }
}
