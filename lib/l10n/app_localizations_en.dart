// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Toyoko Inn Monitor';

  @override
  String get navMonitor => 'Monitor';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navScan => 'Scan';

  @override
  String get navSettings => 'Settings';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabResults => 'Results';

  @override
  String get sectionSearch => 'Search Params';

  @override
  String get labelLocation => 'Location';

  @override
  String get labelCheckin => 'Check-in Date';

  @override
  String get labelNights => 'Nights';

  @override
  String get labelPeople => 'Guests';

  @override
  String get labelRooms => 'Rooms';

  @override
  String get labelRoomType => 'Room Type';

  @override
  String get optionNoPreference => 'No preference';

  @override
  String get optionNoSmoking => 'Non-smoking';

  @override
  String get optionSmoking => 'Smoking';

  @override
  String get labelTargetPrice => 'Target Max Price (¥)';

  @override
  String get hintTargetPrice => 'e.g. 5000, or leave blank';

  @override
  String sectionHotels(int sel, int total) {
    return 'Hotels ($sel/$total)';
  }

  @override
  String get hintHotelSearch => 'Search by hotel name or code';

  @override
  String get btnSelectAll => 'Select All';

  @override
  String get btnSelectNone => 'Deselect All';

  @override
  String get sectionControl => 'Monitor Control';

  @override
  String get labelInterval => 'Check Interval';

  @override
  String get labelStopMode => 'Stop Condition';

  @override
  String get stopModeNever => 'Stop on match';

  @override
  String get stopModeAttempts => 'Max attempts';

  @override
  String get stopModeMinutes => 'Max minutes';

  @override
  String get stopModeMatches => 'Stop after N matches';

  @override
  String unitSeconds(int sec) {
    return '${sec}s';
  }

  @override
  String get btnStopMonitor => 'Stop';

  @override
  String get btnStartMonitor => 'Start Monitoring';

  @override
  String nextCheckLabel(int sec) {
    return 'Next check: ${sec}s';
  }

  @override
  String get tabLivePrices => 'Live Prices';

  @override
  String get tabLog => 'Log';

  @override
  String get tabPriceHistory => 'Price History';

  @override
  String lastUpdateLabel(String time, int n) {
    return 'Last updated: $time (query #$n)';
  }

  @override
  String get noDataYet => 'No data yet. Start monitoring first.';

  @override
  String get columnHotel => 'Hotel';

  @override
  String get columnLowestPrice => 'Lowest Price';

  @override
  String get cantOpenBrowser => 'Cannot open browser';

  @override
  String get noChartData => 'No data';

  @override
  String get pageSettingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeSystem => 'Follow System';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get langZhTW => '繁體中文';

  @override
  String get langJa => '日本語';

  @override
  String get langEn => 'English';

  @override
  String get sectionMatchActions => 'On Price Match';

  @override
  String get autoOpenUrlTitle => 'Auto-open Booking Page';

  @override
  String get autoOpenUrlDesc =>
      'Automatically open the booking page in a browser when a matching hotel is found';

  @override
  String get desktopNotifTitle => 'Desktop Notification';

  @override
  String get desktopNotifDesc =>
      'Show a desktop notification when a matching hotel is found';

  @override
  String get sectionAbout => 'About';

  @override
  String get aboutAppTitle => 'Toyoko Inn Monitor';

  @override
  String get aboutAppSubtitle => 'Hotel price monitor for Toyoko Inn';

  @override
  String get currentVersion => 'Version';

  @override
  String get btnCheckUpdate => 'Check for Updates';

  @override
  String get updateChecking => 'Checking...';

  @override
  String get updateLatest => 'You are on the latest version.';

  @override
  String updateAvailable(String version) {
    return 'New version $version is available!';
  }

  @override
  String get btnDownloadUpdate => 'Update Now';

  @override
  String get updateDownloading => 'Downloading update...';

  @override
  String get updateLaunchingInstaller => 'Starting installer...';

  @override
  String get updateInstallerMissing =>
      'The installer package was not found in this release.';

  @override
  String get updateCheckFailed => 'Could not check for updates.';

  @override
  String get pageTasksTitle => 'Multi-task Monitor';

  @override
  String get addTaskTooltip => 'Add monitor task';

  @override
  String get editTaskTooltip => 'Edit monitor task';

  @override
  String get noTasksMsg => 'No monitor tasks';

  @override
  String get btnAddTask => 'Add Task';

  @override
  String get stopTaskTooltip => 'Stop monitoring';

  @override
  String get startTaskTooltip => 'Start monitoring';

  @override
  String get deleteTaskTooltip => 'Delete task';

  @override
  String get labelTargetShort => 'Target';

  @override
  String get labelLowest => 'Lowest';

  @override
  String get deleteTaskTitle => 'Delete Task';

  @override
  String deleteTaskConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnSave => 'Save';

  @override
  String get btnAdd => 'Add';

  @override
  String get dialogNewTask => 'Add Monitor Task';

  @override
  String get dialogEditTask => 'Edit Monitor Task';

  @override
  String get labelTaskName => 'Task Name';

  @override
  String get hintTaskName => 'Auto-generated or custom';

  @override
  String get noHotelSelected => 'Please select at least one hotel';

  @override
  String get pageScanTitle => 'Date Range Scan';

  @override
  String get labelCity => 'City';

  @override
  String get labelStartDate => 'Start Date';

  @override
  String get labelEndDate => 'End Date';

  @override
  String get btnStartScan => 'Start Scan';

  @override
  String get btnScanning => 'Scanning...';

  @override
  String get btnClear => 'Clear';

  @override
  String get scanHint =>
      'Select city and date range to find the cheapest check-in day';

  @override
  String get noValidPrices => 'No valid prices';

  @override
  String get scanMinLabel => 'Lowest';

  @override
  String get scanMaxLabel => 'Highest';

  @override
  String scanDaysCount(int count) {
    return '$count days scanned';
  }

  @override
  String get dashboardNavActiveMonitors => 'Active Monitors';

  @override
  String dashboardPollingEvery(int sec) {
    return 'Polling every ${sec}s';
  }

  @override
  String get dashboardGlobalAlerts => 'Global Alerts';

  @override
  String get dashboardToggleTheme => 'Toggle theme';

  @override
  String get dashboardThemeLightShort => 'Light';

  @override
  String get dashboardThemeDarkShort => 'Dark';

  @override
  String get dashboardAddMonitor => 'Add Monitor';

  @override
  String get dashboardRunning => 'Running';

  @override
  String get dashboardPaused => 'Paused';

  @override
  String get dashboardAlert => 'Alert';

  @override
  String get dashboardLastUpdated => 'Last updated';

  @override
  String get dashboardDatabase => 'Database';

  @override
  String get dashboardConnected => 'Connected';

  @override
  String get dashboardPolling => 'Polling';

  @override
  String get dashboardIdle => 'Idle';

  @override
  String get dashboardMetricLowestPrice => 'LOWEST PRICE';

  @override
  String get dashboardMetricLowestPriceHelper => 'Across all active monitors';

  @override
  String get dashboardMetricTargetHitRate => 'TARGET HIT RATE';

  @override
  String dashboardMetricHitRateHelper(int alerts, int tasks) {
    return '$alerts alert / $tasks tasks';
  }

  @override
  String get dashboardMetricActiveMonitors => 'ACTIVE MONITORS';

  @override
  String dashboardMetricActiveHelper(int running, int paused) {
    return '$running running / $paused paused';
  }

  @override
  String dashboardTasksCount(int count) {
    return '$count tasks';
  }

  @override
  String get dashboardNoMonitorTasks => 'No monitor tasks';

  @override
  String get dashboardNoMonitorTasksMessage =>
      'Add a monitor to start tracking hotel prices.';

  @override
  String get dashboardRefreshView => 'Refresh view';

  @override
  String get dashboardDeleteMonitorTitle => 'Delete monitor';

  @override
  String dashboardDeleteMonitorConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get dashboardColumnHotelPlan => 'Hotel / Plan';

  @override
  String get dashboardColumnStatus => 'Status';

  @override
  String get dashboardColumnVsTarget => 'vs Target';

  @override
  String get dashboardColumnLastUpdate => 'Last Update';

  @override
  String get dashboardColumnActions => 'Actions';

  @override
  String dashboardRoomGuestSummary(int rooms, int guests) {
    return '$rooms room / $guests guests';
  }

  @override
  String get dashboardRun => 'Run';

  @override
  String get dashboardPause => 'Pause';

  @override
  String get dashboardOpenBooking => 'Open booking';

  @override
  String get dashboardNotAvailable => 'n/a';

  @override
  String dashboardNights(int count) {
    return '$count nights';
  }

  @override
  String get dashboardTaskDetails => 'Task Details';

  @override
  String get dashboardCheckOut => 'Check-out';

  @override
  String get dashboardSelectedHotels => 'Selected Hotels';

  @override
  String get dashboardMatchedRooms => 'Matched Rooms';

  @override
  String get dashboardError => 'Error';

  @override
  String get dashboardPriceTrend => 'Price Trend';

  @override
  String get dashboardLiveMonitor => 'Live monitor';

  @override
  String dashboardTargetPrice(String price) {
    return 'Target $price';
  }

  @override
  String get dashboardNoTrendData => 'No trend data';

  @override
  String get dashboardNoTrendDataMessage =>
      'Start polling to draw live price movement.';

  @override
  String get dashboardDateRangePrices => 'Date Range Prices';

  @override
  String get dashboardCheapestCheckinDays => 'Cheapest check-in days';

  @override
  String get dashboardNoScanData => 'No scan data';

  @override
  String get dashboardNoScanDataMessage =>
      'Run Date Range Scan to compare dates.';

  @override
  String get dashboardLowestLegend => 'Lowest';

  @override
  String get dashboardNearTarget => 'Near target';

  @override
  String get dashboardHigh => 'High';

  @override
  String get dashboardLocationDistribution => 'Location Distribution';

  @override
  String get dashboardAllMonitors => 'All monitors';

  @override
  String get dashboardNoDistribution => 'No distribution';

  @override
  String get dashboardNoDistributionMessage =>
      'Create monitor tasks to see location mix.';

  @override
  String get dashboardAlertFeed => 'Alert Feed';

  @override
  String get dashboardRealTime => 'Real-time';

  @override
  String get dashboardNoAlerts => 'No alerts';

  @override
  String get dashboardNoAlertsMessage =>
      'Matches and price warnings appear here.';

  @override
  String dashboardTargetSuffix(String price) {
    return ' / target $price';
  }

  @override
  String get dashboardPriceAboveTarget => 'Price above target';

  @override
  String get dashboardPriceNearTarget => 'Price near target';

  @override
  String get dashboardTargetHit => 'Target hit';

  @override
  String get dashboardPriceHistory => 'Price History';

  @override
  String get dashboardStoredPollingResults => 'Stored polling results';

  @override
  String get dashboardMonitorTask => 'Monitor task';

  @override
  String get dashboardNoTaskSelected => 'No task selected';

  @override
  String get dashboardNoTaskSelectedMessage =>
      'Create a monitor task to collect history.';

  @override
  String get dashboardCouldNotLoadHistory => 'Could not load history';

  @override
  String get dashboardNoStoredPrices => 'No stored prices';

  @override
  String get dashboardNoStoredPricesMessage =>
      'History appears after a monitor records poll results.';

  @override
  String dashboardHistoryPoints(String code, int count) {
    return '$code  $count points';
  }
}
