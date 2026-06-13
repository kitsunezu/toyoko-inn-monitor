import 'dart:io';

import 'package:dio/dio.dart';
import '../constants.dart';

enum UpdateStatus {
  idle,
  checking,
  latest,
  available,
  downloading,
  launchingInstaller,
  failed,
}

class UpdateInfo {
  final UpdateStatus status;
  final String? latestVersion;
  final String? installerUrl;

  const UpdateInfo(this.status, {this.latestVersion, this.installerUrl});

  static const idle = UpdateInfo(UpdateStatus.idle);
  static const checking = UpdateInfo(UpdateStatus.checking);
  static const latest = UpdateInfo(UpdateStatus.latest);
  static const failed = UpdateInfo(UpdateStatus.failed);
}

class ReleaseAsset {
  final String name;
  final String downloadUrl;

  const ReleaseAsset({required this.name, required this.downloadUrl});
}

class UpdateRelease {
  final String tagName;
  final ReleaseAsset? installerAsset;

  const UpdateRelease({required this.tagName, required this.installerAsset});
}

class UpdateService {
  final Dio _dio;

  UpdateService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent':
              '${AppConstants.githubOwner}-${AppConstants.githubRepo}',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      ),
    );
  }

  /// Returns the latest release tag from GitHub (e.g. "v1.2.0"),
  /// or null if the request fails.
  Future<String?> fetchLatestTag() async {
    final release = await fetchLatestRelease();
    return release?.tagName;
  }

  /// Returns latest release metadata including the Windows installer asset.
  Future<UpdateRelease?> fetchLatestRelease() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        AppConstants.githubReleasesApiUrl,
      );
      return parseRelease(resp.data);
    } catch (_) {
      return null;
    }
  }

  UpdateRelease? parseRelease(Map<String, dynamic>? data) {
    final tag = data?['tag_name'] as String?;
    if (tag == null || tag.trim().isEmpty) {
      return null;
    }

    final rawAssets = data?['assets'];
    final installerAsset = rawAssets is List
        ? findInstallerAsset(rawAssets)
        : null;

    return UpdateRelease(tagName: tag, installerAsset: installerAsset);
  }

  ReleaseAsset? findInstallerAsset(List<dynamic> assets) {
    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) {
        continue;
      }

      final name = asset['name'] as String?;
      final url = asset['browser_download_url'] as String?;
      if (name == null || url == null) {
        continue;
      }

      if (_isWindowsInstallerName(name)) {
        return ReleaseAsset(name: name, downloadUrl: url);
      }
    }
    return null;
  }

  Future<File> downloadInstaller({
    required String downloadUrl,
    required String latestVersion,
  }) async {
    final fileName = _downloadFileName(downloadUrl, latestVersion);
    final targetDir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}toyoko_inn_monitor_update',
    );
    await targetDir.create(recursive: true);

    final target = File('${targetDir.path}${Platform.pathSeparator}$fileName');
    await _dio.download(
      downloadUrl,
      target.path,
      options: Options(headers: {'Accept': 'application/octet-stream'}),
    );
    return target;
  }

  Future<void> launchInstaller(File installer) async {
    await Process.start(
      installer.path,
      const [],
      mode: ProcessStartMode.detached,
    );
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

  bool _isWindowsInstallerName(String name) {
    return RegExp(
      r'^ToyokoInnMonitor-.+-setup\.exe$',
      caseSensitive: false,
    ).hasMatch(name);
  }

  String _downloadFileName(String downloadUrl, String latestVersion) {
    final parsed = Uri.tryParse(downloadUrl);
    final segment = parsed?.pathSegments.isNotEmpty == true
        ? parsed!.pathSegments.last
        : '';
    if (segment.toLowerCase().endsWith('.exe')) {
      return segment.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    }

    final version = latestVersion.trim().replaceFirst(RegExp(r'^[vV]'), '');
    return 'ToyokoInnMonitor-$version-setup.exe';
  }
}
