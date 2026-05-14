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
  String get optionNoSmoking => 'Non-smoking';

  @override
  String get optionSmoking => 'Smoking';

  @override
  String get labelTargetPrice => 'Target Max Price (¥)';

  @override
  String get hintTargetPrice => 'e.g. 5000';

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
  String get btnDownloadUpdate => 'Download Update';

  @override
  String get updateCheckFailed => 'Could not check for updates.';

  @override
  String get pageTasksTitle => 'Multi-task Monitor';

  @override
  String get addTaskTooltip => 'Add monitor task';

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
  String get btnAdd => 'Add';

  @override
  String get dialogNewTask => 'Add Monitor Task';

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
}
