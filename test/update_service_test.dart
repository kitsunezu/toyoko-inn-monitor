import 'package:flutter_test/flutter_test.dart';
import 'package:toyoko_inn_monitor/core/constants.dart';
import 'package:toyoko_inn_monitor/core/services/update_service.dart';

void main() {
  group('AppConstants GitHub release URLs', () {
    test('point to the published repository', () {
      expect(AppConstants.githubOwner, 'kitsunezu');
      expect(AppConstants.githubRepo, 'toyoko-inn-monitor');
      expect(
        AppConstants.githubReleasesApiUrl,
        'https://api.github.com/repos/kitsunezu/toyoko-inn-monitor/releases/latest',
      );
      expect(
        AppConstants.githubReleasesPageUrl,
        'https://github.com/kitsunezu/toyoko-inn-monitor/releases/latest',
      );
    });
  });

  group('UpdateService.isNewer', () {
    test('detects newer GitHub tags', () {
      final service = UpdateService();

      expect(service.isNewer('v1.0.2', '1.0.1'), isTrue);
      expect(service.isNewer('v1.10.0', '1.9.9'), isTrue);
      expect(service.isNewer('1.0.1', '1.0.1'), isFalse);
    });

    test('handles tag prefixes and pubspec build metadata', () {
      final service = UpdateService();

      expect(service.isNewer('V1.0.2', '1.0.1+2'), isTrue);
      expect(service.isNewer('v1.0.1', '1.0.1+2'), isFalse);
      expect(service.isNewer('v1.0.1-beta.1', '1.0.0'), isTrue);
    });
  });

  group('UpdateService.parseRelease', () {
    test(
      'extracts the Windows installer asset from latest release metadata',
      () {
        final service = UpdateService();

        final release = service.parseRelease({
          'tag_name': 'v1.0.4',
          'assets': [
            {
              'name': 'ToyokoInnMonitor-1.0.4-portable.zip',
              'browser_download_url':
                  'https://example.com/ToyokoInnMonitor-1.0.4-portable.zip',
            },
            {
              'name': 'ToyokoInnMonitor-1.0.4-setup.exe',
              'browser_download_url':
                  'https://example.com/ToyokoInnMonitor-1.0.4-setup.exe',
            },
          ],
        });

        expect(release?.tagName, 'v1.0.4');
        expect(
          release?.installerAsset?.name,
          'ToyokoInnMonitor-1.0.4-setup.exe',
        );
        expect(
          release?.installerAsset?.downloadUrl,
          'https://example.com/ToyokoInnMonitor-1.0.4-setup.exe',
        );
      },
    );

    test('keeps release metadata when installer asset is missing', () {
      final service = UpdateService();

      final release = service.parseRelease({
        'tag_name': 'v1.0.4',
        'assets': [
          {
            'name': 'ToyokoInnMonitor-1.0.4-portable.zip',
            'browser_download_url':
                'https://example.com/ToyokoInnMonitor-1.0.4-portable.zip',
          },
        ],
      });

      expect(release?.tagName, 'v1.0.4');
      expect(release?.installerAsset, isNull);
    });
  });
}
