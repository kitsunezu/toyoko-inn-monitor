import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'東橫 INN 監控器'**
  String get appTitle;

  /// No description provided for @navMonitor.
  ///
  /// In zh, this message translates to:
  /// **'監控'**
  String get navMonitor;

  /// No description provided for @navTasks.
  ///
  /// In zh, this message translates to:
  /// **'任務'**
  String get navTasks;

  /// No description provided for @navScan.
  ///
  /// In zh, this message translates to:
  /// **'掃描'**
  String get navScan;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'設定'**
  String get navSettings;

  /// No description provided for @tabSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜尋設定'**
  String get tabSearch;

  /// No description provided for @tabResults.
  ///
  /// In zh, this message translates to:
  /// **'結果'**
  String get tabResults;

  /// No description provided for @sectionSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜尋條件'**
  String get sectionSearch;

  /// No description provided for @labelLocation.
  ///
  /// In zh, this message translates to:
  /// **'地點'**
  String get labelLocation;

  /// No description provided for @labelCheckin.
  ///
  /// In zh, this message translates to:
  /// **'入住日期'**
  String get labelCheckin;

  /// No description provided for @labelNights.
  ///
  /// In zh, this message translates to:
  /// **'晚數'**
  String get labelNights;

  /// No description provided for @labelPeople.
  ///
  /// In zh, this message translates to:
  /// **'人數'**
  String get labelPeople;

  /// No description provided for @labelRooms.
  ///
  /// In zh, this message translates to:
  /// **'房間數'**
  String get labelRooms;

  /// No description provided for @labelRoomType.
  ///
  /// In zh, this message translates to:
  /// **'房型'**
  String get labelRoomType;

  /// No description provided for @optionNoSmoking.
  ///
  /// In zh, this message translates to:
  /// **'禁煙'**
  String get optionNoSmoking;

  /// No description provided for @optionSmoking.
  ///
  /// In zh, this message translates to:
  /// **'吸煙'**
  String get optionSmoking;

  /// No description provided for @labelTargetPrice.
  ///
  /// In zh, this message translates to:
  /// **'目標最高價 (¥)'**
  String get labelTargetPrice;

  /// No description provided for @hintTargetPrice.
  ///
  /// In zh, this message translates to:
  /// **'例: 5000，可留空'**
  String get hintTargetPrice;

  /// No description provided for @sectionHotels.
  ///
  /// In zh, this message translates to:
  /// **'飯店選擇 ({sel}/{total})'**
  String sectionHotels(int sel, int total);

  /// No description provided for @hintHotelSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜尋飯店名稱或代碼'**
  String get hintHotelSearch;

  /// No description provided for @btnSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全選'**
  String get btnSelectAll;

  /// No description provided for @btnSelectNone.
  ///
  /// In zh, this message translates to:
  /// **'全不選'**
  String get btnSelectNone;

  /// No description provided for @sectionControl.
  ///
  /// In zh, this message translates to:
  /// **'監控控制'**
  String get sectionControl;

  /// No description provided for @labelInterval.
  ///
  /// In zh, this message translates to:
  /// **'查詢間隔'**
  String get labelInterval;

  /// No description provided for @labelStopMode.
  ///
  /// In zh, this message translates to:
  /// **'停止條件'**
  String get labelStopMode;

  /// No description provided for @stopModeNever.
  ///
  /// In zh, this message translates to:
  /// **'找到後停止'**
  String get stopModeNever;

  /// No description provided for @stopModeAttempts.
  ///
  /// In zh, this message translates to:
  /// **'最多次數'**
  String get stopModeAttempts;

  /// No description provided for @stopModeMinutes.
  ///
  /// In zh, this message translates to:
  /// **'最多分鐘'**
  String get stopModeMinutes;

  /// No description provided for @stopModeMatches.
  ///
  /// In zh, this message translates to:
  /// **'找到N筆停止'**
  String get stopModeMatches;

  /// No description provided for @unitSeconds.
  ///
  /// In zh, this message translates to:
  /// **'{sec} 秒'**
  String unitSeconds(int sec);

  /// No description provided for @btnStopMonitor.
  ///
  /// In zh, this message translates to:
  /// **'停止監控'**
  String get btnStopMonitor;

  /// No description provided for @btnStartMonitor.
  ///
  /// In zh, this message translates to:
  /// **'開始監控'**
  String get btnStartMonitor;

  /// No description provided for @nextCheckLabel.
  ///
  /// In zh, this message translates to:
  /// **'下次查詢: {sec} 秒'**
  String nextCheckLabel(int sec);

  /// No description provided for @tabLivePrices.
  ///
  /// In zh, this message translates to:
  /// **'即時價格'**
  String get tabLivePrices;

  /// No description provided for @tabLog.
  ///
  /// In zh, this message translates to:
  /// **'日誌'**
  String get tabLog;

  /// No description provided for @tabPriceHistory.
  ///
  /// In zh, this message translates to:
  /// **'價格歷史'**
  String get tabPriceHistory;

  /// No description provided for @lastUpdateLabel.
  ///
  /// In zh, this message translates to:
  /// **'最後更新: {time}（第 {n} 次查詢）'**
  String lastUpdateLabel(String time, int n);

  /// No description provided for @noDataYet.
  ///
  /// In zh, this message translates to:
  /// **'尚無資料，請先開始監控'**
  String get noDataYet;

  /// No description provided for @columnHotel.
  ///
  /// In zh, this message translates to:
  /// **'飯店'**
  String get columnHotel;

  /// No description provided for @columnLowestPrice.
  ///
  /// In zh, this message translates to:
  /// **'最低價'**
  String get columnLowestPrice;

  /// No description provided for @cantOpenBrowser.
  ///
  /// In zh, this message translates to:
  /// **'無法開啟瀏覽器'**
  String get cantOpenBrowser;

  /// No description provided for @noChartData.
  ///
  /// In zh, this message translates to:
  /// **'尚無資料'**
  String get noChartData;

  /// No description provided for @pageSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'設定'**
  String get pageSettingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外觀'**
  String get sectionAppearance;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色主題'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'淺色主題'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟隨系統'**
  String get themeSystem;

  /// No description provided for @sectionLanguage.
  ///
  /// In zh, this message translates to:
  /// **'語言'**
  String get sectionLanguage;

  /// No description provided for @langZhTW.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get langZhTW;

  /// No description provided for @langJa.
  ///
  /// In zh, this message translates to:
  /// **'日本語'**
  String get langJa;

  /// No description provided for @langEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @sectionMatchActions.
  ///
  /// In zh, this message translates to:
  /// **'找到符合目標價時'**
  String get sectionMatchActions;

  /// No description provided for @autoOpenUrlTitle.
  ///
  /// In zh, this message translates to:
  /// **'自動開啟網頁'**
  String get autoOpenUrlTitle;

  /// No description provided for @autoOpenUrlDesc.
  ///
  /// In zh, this message translates to:
  /// **'找到符合目標價的飯店時，自動在瀏覽器開啟訂房頁面'**
  String get autoOpenUrlDesc;

  /// No description provided for @desktopNotifTitle.
  ///
  /// In zh, this message translates to:
  /// **'桌面通知'**
  String get desktopNotifTitle;

  /// No description provided for @desktopNotifDesc.
  ///
  /// In zh, this message translates to:
  /// **'找到符合目標價的飯店時，顯示桌面通知'**
  String get desktopNotifDesc;

  /// No description provided for @sectionAbout.
  ///
  /// In zh, this message translates to:
  /// **'關於'**
  String get sectionAbout;

  /// No description provided for @aboutAppTitle.
  ///
  /// In zh, this message translates to:
  /// **'東橫 INN 監控器'**
  String get aboutAppTitle;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'東橫 INN 飯店房價監控工具'**
  String get aboutAppSubtitle;

  /// No description provided for @currentVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get currentVersion;

  /// No description provided for @btnCheckUpdate.
  ///
  /// In zh, this message translates to:
  /// **'檢查更新'**
  String get btnCheckUpdate;

  /// No description provided for @updateChecking.
  ///
  /// In zh, this message translates to:
  /// **'檢查中...'**
  String get updateChecking;

  /// No description provided for @updateLatest.
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本。'**
  String get updateLatest;

  /// No description provided for @updateAvailable.
  ///
  /// In zh, this message translates to:
  /// **'有新版本 {version} 可用！'**
  String updateAvailable(String version);

  /// No description provided for @btnDownloadUpdate.
  ///
  /// In zh, this message translates to:
  /// **'下載更新'**
  String get btnDownloadUpdate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法檢查更新。'**
  String get updateCheckFailed;

  /// No description provided for @pageTasksTitle.
  ///
  /// In zh, this message translates to:
  /// **'多任務監控'**
  String get pageTasksTitle;

  /// No description provided for @addTaskTooltip.
  ///
  /// In zh, this message translates to:
  /// **'新增監控任務'**
  String get addTaskTooltip;

  /// No description provided for @editTaskTooltip.
  ///
  /// In zh, this message translates to:
  /// **'修改監控任務'**
  String get editTaskTooltip;

  /// No description provided for @noTasksMsg.
  ///
  /// In zh, this message translates to:
  /// **'尚無監控任務'**
  String get noTasksMsg;

  /// No description provided for @btnAddTask.
  ///
  /// In zh, this message translates to:
  /// **'新增任務'**
  String get btnAddTask;

  /// No description provided for @stopTaskTooltip.
  ///
  /// In zh, this message translates to:
  /// **'停止監控'**
  String get stopTaskTooltip;

  /// No description provided for @startTaskTooltip.
  ///
  /// In zh, this message translates to:
  /// **'開始監控'**
  String get startTaskTooltip;

  /// No description provided for @deleteTaskTooltip.
  ///
  /// In zh, this message translates to:
  /// **'刪除任務'**
  String get deleteTaskTooltip;

  /// No description provided for @labelTargetShort.
  ///
  /// In zh, this message translates to:
  /// **'目標'**
  String get labelTargetShort;

  /// No description provided for @labelLowest.
  ///
  /// In zh, this message translates to:
  /// **'最低'**
  String get labelLowest;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In zh, this message translates to:
  /// **'刪除任務'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定刪除「{name}」？'**
  String deleteTaskConfirm(String name);

  /// No description provided for @btnCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get btnCancel;

  /// No description provided for @btnDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get btnDelete;

  /// No description provided for @btnSave.
  ///
  /// In zh, this message translates to:
  /// **'儲存'**
  String get btnSave;

  /// No description provided for @btnAdd.
  ///
  /// In zh, this message translates to:
  /// **'新增'**
  String get btnAdd;

  /// No description provided for @dialogNewTask.
  ///
  /// In zh, this message translates to:
  /// **'新增監控任務'**
  String get dialogNewTask;

  /// No description provided for @dialogEditTask.
  ///
  /// In zh, this message translates to:
  /// **'修改監控任務'**
  String get dialogEditTask;

  /// No description provided for @labelTaskName.
  ///
  /// In zh, this message translates to:
  /// **'任務名稱'**
  String get labelTaskName;

  /// No description provided for @hintTaskName.
  ///
  /// In zh, this message translates to:
  /// **'自動產生或自訂'**
  String get hintTaskName;

  /// No description provided for @noHotelSelected.
  ///
  /// In zh, this message translates to:
  /// **'請至少選擇一間飯店'**
  String get noHotelSelected;

  /// No description provided for @pageScanTitle.
  ///
  /// In zh, this message translates to:
  /// **'日期範圍掃描'**
  String get pageScanTitle;

  /// No description provided for @labelCity.
  ///
  /// In zh, this message translates to:
  /// **'城市'**
  String get labelCity;

  /// No description provided for @labelStartDate.
  ///
  /// In zh, this message translates to:
  /// **'起始日'**
  String get labelStartDate;

  /// No description provided for @labelEndDate.
  ///
  /// In zh, this message translates to:
  /// **'結束日'**
  String get labelEndDate;

  /// No description provided for @btnStartScan.
  ///
  /// In zh, this message translates to:
  /// **'開始掃描'**
  String get btnStartScan;

  /// No description provided for @btnScanning.
  ///
  /// In zh, this message translates to:
  /// **'掃描中...'**
  String get btnScanning;

  /// No description provided for @btnClear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get btnClear;

  /// No description provided for @scanHint.
  ///
  /// In zh, this message translates to:
  /// **'選擇城市和日期範圍後開始掃描，查找最便宜的入住日'**
  String get scanHint;

  /// No description provided for @noValidPrices.
  ///
  /// In zh, this message translates to:
  /// **'無有效報價'**
  String get noValidPrices;

  /// No description provided for @scanMinLabel.
  ///
  /// In zh, this message translates to:
  /// **'最低'**
  String get scanMinLabel;

  /// No description provided for @scanMaxLabel.
  ///
  /// In zh, this message translates to:
  /// **'最高'**
  String get scanMaxLabel;

  /// No description provided for @scanDaysCount.
  ///
  /// In zh, this message translates to:
  /// **'共掃描 {count} 天'**
  String scanDaysCount(int count);

  /// No description provided for @dashboardNavActiveMonitors.
  ///
  /// In zh, this message translates to:
  /// **'即時監控'**
  String get dashboardNavActiveMonitors;

  /// No description provided for @dashboardPollingEvery.
  ///
  /// In zh, this message translates to:
  /// **'每 {sec} 秒輪詢'**
  String dashboardPollingEvery(int sec);

  /// No description provided for @dashboardGlobalAlerts.
  ///
  /// In zh, this message translates to:
  /// **'全域警報'**
  String get dashboardGlobalAlerts;

  /// No description provided for @dashboardToggleTheme.
  ///
  /// In zh, this message translates to:
  /// **'切換主題'**
  String get dashboardToggleTheme;

  /// No description provided for @dashboardThemeLightShort.
  ///
  /// In zh, this message translates to:
  /// **'淺色'**
  String get dashboardThemeLightShort;

  /// No description provided for @dashboardThemeDarkShort.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get dashboardThemeDarkShort;

  /// No description provided for @dashboardAddMonitor.
  ///
  /// In zh, this message translates to:
  /// **'新增監控'**
  String get dashboardAddMonitor;

  /// No description provided for @dashboardRunning.
  ///
  /// In zh, this message translates to:
  /// **'執行中'**
  String get dashboardRunning;

  /// No description provided for @dashboardPaused.
  ///
  /// In zh, this message translates to:
  /// **'已暫停'**
  String get dashboardPaused;

  /// No description provided for @dashboardAlert.
  ///
  /// In zh, this message translates to:
  /// **'警報'**
  String get dashboardAlert;

  /// No description provided for @dashboardLastUpdated.
  ///
  /// In zh, this message translates to:
  /// **'最後更新'**
  String get dashboardLastUpdated;

  /// No description provided for @dashboardDatabase.
  ///
  /// In zh, this message translates to:
  /// **'資料庫'**
  String get dashboardDatabase;

  /// No description provided for @dashboardConnected.
  ///
  /// In zh, this message translates to:
  /// **'已連線'**
  String get dashboardConnected;

  /// No description provided for @dashboardPolling.
  ///
  /// In zh, this message translates to:
  /// **'輪詢'**
  String get dashboardPolling;

  /// No description provided for @dashboardIdle.
  ///
  /// In zh, this message translates to:
  /// **'待命'**
  String get dashboardIdle;

  /// No description provided for @dashboardMetricLowestPrice.
  ///
  /// In zh, this message translates to:
  /// **'目前最低價'**
  String get dashboardMetricLowestPrice;

  /// No description provided for @dashboardMetricLowestPriceHelper.
  ///
  /// In zh, this message translates to:
  /// **'所有啟用監控'**
  String get dashboardMetricLowestPriceHelper;

  /// No description provided for @dashboardMetricTargetHitRate.
  ///
  /// In zh, this message translates to:
  /// **'目標達成率'**
  String get dashboardMetricTargetHitRate;

  /// No description provided for @dashboardMetricHitRateHelper.
  ///
  /// In zh, this message translates to:
  /// **'{alerts} 個警報 / {tasks} 個任務'**
  String dashboardMetricHitRateHelper(int alerts, int tasks);

  /// No description provided for @dashboardMetricActiveMonitors.
  ///
  /// In zh, this message translates to:
  /// **'啟用監控'**
  String get dashboardMetricActiveMonitors;

  /// No description provided for @dashboardMetricActiveHelper.
  ///
  /// In zh, this message translates to:
  /// **'{running} 執行中 / {paused} 已暫停'**
  String dashboardMetricActiveHelper(int running, int paused);

  /// No description provided for @dashboardTasksCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 個任務'**
  String dashboardTasksCount(int count);

  /// No description provided for @dashboardNoMonitorTasks.
  ///
  /// In zh, this message translates to:
  /// **'尚無監控任務'**
  String get dashboardNoMonitorTasks;

  /// No description provided for @dashboardNoMonitorTasksMessage.
  ///
  /// In zh, this message translates to:
  /// **'新增監控後即可開始追蹤飯店價格。'**
  String get dashboardNoMonitorTasksMessage;

  /// No description provided for @dashboardRefreshView.
  ///
  /// In zh, this message translates to:
  /// **'重新整理'**
  String get dashboardRefreshView;

  /// No description provided for @dashboardDeleteMonitorTitle.
  ///
  /// In zh, this message translates to:
  /// **'刪除監控'**
  String get dashboardDeleteMonitorTitle;

  /// No description provided for @dashboardDeleteMonitorConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定刪除「{name}」？'**
  String dashboardDeleteMonitorConfirm(String name);

  /// No description provided for @dashboardColumnHotelPlan.
  ///
  /// In zh, this message translates to:
  /// **'飯店 / 方案'**
  String get dashboardColumnHotelPlan;

  /// No description provided for @dashboardColumnStatus.
  ///
  /// In zh, this message translates to:
  /// **'狀態'**
  String get dashboardColumnStatus;

  /// No description provided for @dashboardColumnVsTarget.
  ///
  /// In zh, this message translates to:
  /// **'相差目標'**
  String get dashboardColumnVsTarget;

  /// No description provided for @dashboardColumnLastUpdate.
  ///
  /// In zh, this message translates to:
  /// **'最後更新'**
  String get dashboardColumnLastUpdate;

  /// No description provided for @dashboardColumnActions.
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get dashboardColumnActions;

  /// No description provided for @dashboardRoomGuestSummary.
  ///
  /// In zh, this message translates to:
  /// **'{rooms} 間房 / {guests} 人'**
  String dashboardRoomGuestSummary(int rooms, int guests);

  /// No description provided for @dashboardRun.
  ///
  /// In zh, this message translates to:
  /// **'啟動'**
  String get dashboardRun;

  /// No description provided for @dashboardPause.
  ///
  /// In zh, this message translates to:
  /// **'暫停'**
  String get dashboardPause;

  /// No description provided for @dashboardOpenBooking.
  ///
  /// In zh, this message translates to:
  /// **'開啟訂房'**
  String get dashboardOpenBooking;

  /// No description provided for @dashboardNotAvailable.
  ///
  /// In zh, this message translates to:
  /// **'無'**
  String get dashboardNotAvailable;

  /// No description provided for @dashboardNights.
  ///
  /// In zh, this message translates to:
  /// **'{count} 晚'**
  String dashboardNights(int count);

  /// No description provided for @dashboardTaskDetails.
  ///
  /// In zh, this message translates to:
  /// **'任務詳細'**
  String get dashboardTaskDetails;

  /// No description provided for @dashboardCheckOut.
  ///
  /// In zh, this message translates to:
  /// **'退房日'**
  String get dashboardCheckOut;

  /// No description provided for @dashboardSelectedHotels.
  ///
  /// In zh, this message translates to:
  /// **'已選飯店'**
  String get dashboardSelectedHotels;

  /// No description provided for @dashboardMatchedRooms.
  ///
  /// In zh, this message translates to:
  /// **'符合房型'**
  String get dashboardMatchedRooms;

  /// No description provided for @dashboardError.
  ///
  /// In zh, this message translates to:
  /// **'錯誤'**
  String get dashboardError;

  /// No description provided for @dashboardPriceTrend.
  ///
  /// In zh, this message translates to:
  /// **'價格趨勢'**
  String get dashboardPriceTrend;

  /// No description provided for @dashboardLiveMonitor.
  ///
  /// In zh, this message translates to:
  /// **'即時監控'**
  String get dashboardLiveMonitor;

  /// No description provided for @dashboardTargetPrice.
  ///
  /// In zh, this message translates to:
  /// **'目標 {price}'**
  String dashboardTargetPrice(String price);

  /// No description provided for @dashboardNoTrendData.
  ///
  /// In zh, this message translates to:
  /// **'尚無趨勢資料'**
  String get dashboardNoTrendData;

  /// No description provided for @dashboardNoTrendDataMessage.
  ///
  /// In zh, this message translates to:
  /// **'開始輪詢後會繪製即時價格走勢。'**
  String get dashboardNoTrendDataMessage;

  /// No description provided for @dashboardDateRangePrices.
  ///
  /// In zh, this message translates to:
  /// **'日期價格'**
  String get dashboardDateRangePrices;

  /// No description provided for @dashboardCheapestCheckinDays.
  ///
  /// In zh, this message translates to:
  /// **'最便宜入住日'**
  String get dashboardCheapestCheckinDays;

  /// No description provided for @dashboardNoScanData.
  ///
  /// In zh, this message translates to:
  /// **'尚無掃描資料'**
  String get dashboardNoScanData;

  /// No description provided for @dashboardNoScanDataMessage.
  ///
  /// In zh, this message translates to:
  /// **'執行日期範圍掃描以比較各日期。'**
  String get dashboardNoScanDataMessage;

  /// No description provided for @dashboardLowestLegend.
  ///
  /// In zh, this message translates to:
  /// **'最低'**
  String get dashboardLowestLegend;

  /// No description provided for @dashboardNearTarget.
  ///
  /// In zh, this message translates to:
  /// **'接近目標'**
  String get dashboardNearTarget;

  /// No description provided for @dashboardHigh.
  ///
  /// In zh, this message translates to:
  /// **'偏高'**
  String get dashboardHigh;

  /// No description provided for @dashboardLocationDistribution.
  ///
  /// In zh, this message translates to:
  /// **'地點分布'**
  String get dashboardLocationDistribution;

  /// No description provided for @dashboardAllMonitors.
  ///
  /// In zh, this message translates to:
  /// **'全部監控'**
  String get dashboardAllMonitors;

  /// No description provided for @dashboardNoDistribution.
  ///
  /// In zh, this message translates to:
  /// **'尚無分布資料'**
  String get dashboardNoDistribution;

  /// No description provided for @dashboardNoDistributionMessage.
  ///
  /// In zh, this message translates to:
  /// **'建立監控任務後即可查看地點分布。'**
  String get dashboardNoDistributionMessage;

  /// No description provided for @dashboardAlertFeed.
  ///
  /// In zh, this message translates to:
  /// **'即時警報'**
  String get dashboardAlertFeed;

  /// No description provided for @dashboardRealTime.
  ///
  /// In zh, this message translates to:
  /// **'即時'**
  String get dashboardRealTime;

  /// No description provided for @dashboardNoAlerts.
  ///
  /// In zh, this message translates to:
  /// **'尚無警報'**
  String get dashboardNoAlerts;

  /// No description provided for @dashboardNoAlertsMessage.
  ///
  /// In zh, this message translates to:
  /// **'符合目標價與價格警告會顯示在這裡。'**
  String get dashboardNoAlertsMessage;

  /// No description provided for @dashboardTargetSuffix.
  ///
  /// In zh, this message translates to:
  /// **' / 目標 {price}'**
  String dashboardTargetSuffix(String price);

  /// No description provided for @dashboardPriceAboveTarget.
  ///
  /// In zh, this message translates to:
  /// **'高於目標價'**
  String get dashboardPriceAboveTarget;

  /// No description provided for @dashboardPriceNearTarget.
  ///
  /// In zh, this message translates to:
  /// **'接近目標價'**
  String get dashboardPriceNearTarget;

  /// No description provided for @dashboardTargetHit.
  ///
  /// In zh, this message translates to:
  /// **'達成目標價'**
  String get dashboardTargetHit;

  /// No description provided for @dashboardPriceHistory.
  ///
  /// In zh, this message translates to:
  /// **'價格歷史'**
  String get dashboardPriceHistory;

  /// No description provided for @dashboardStoredPollingResults.
  ///
  /// In zh, this message translates to:
  /// **'已儲存輪詢結果'**
  String get dashboardStoredPollingResults;

  /// No description provided for @dashboardMonitorTask.
  ///
  /// In zh, this message translates to:
  /// **'監控任務'**
  String get dashboardMonitorTask;

  /// No description provided for @dashboardNoTaskSelected.
  ///
  /// In zh, this message translates to:
  /// **'尚未選擇任務'**
  String get dashboardNoTaskSelected;

  /// No description provided for @dashboardNoTaskSelectedMessage.
  ///
  /// In zh, this message translates to:
  /// **'建立監控任務後即可累積歷史資料。'**
  String get dashboardNoTaskSelectedMessage;

  /// No description provided for @dashboardCouldNotLoadHistory.
  ///
  /// In zh, this message translates to:
  /// **'無法載入歷史資料'**
  String get dashboardCouldNotLoadHistory;

  /// No description provided for @dashboardNoStoredPrices.
  ///
  /// In zh, this message translates to:
  /// **'尚無儲存價格'**
  String get dashboardNoStoredPrices;

  /// No description provided for @dashboardNoStoredPricesMessage.
  ///
  /// In zh, this message translates to:
  /// **'監控記錄輪詢結果後會顯示歷史資料。'**
  String get dashboardNoStoredPricesMessage;

  /// No description provided for @dashboardHistoryPoints.
  ///
  /// In zh, this message translates to:
  /// **'{code}  {count} 筆'**
  String dashboardHistoryPoints(String code, int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
