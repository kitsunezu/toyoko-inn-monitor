/// Centralised app-level constants.
class AppConstants {
  AppConstants._();

  static const String githubOwner = 'YOUR_GITHUB_USERNAME';
  static const String githubRepo = 'toyoko_inn_monitor';

  static const String githubReleasesApiUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  static const String githubReleasesPageUrl =
      'https://github.com/$githubOwner/$githubRepo/releases/latest';
}
