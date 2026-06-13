// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '東橫 INN 監控器';

  @override
  String get navMonitor => '監控';

  @override
  String get navTasks => '任務';

  @override
  String get navScan => '掃描';

  @override
  String get navSettings => '設定';

  @override
  String get tabSearch => '搜尋設定';

  @override
  String get tabResults => '結果';

  @override
  String get sectionSearch => '搜尋條件';

  @override
  String get labelLocation => '地點';

  @override
  String get labelCheckin => '入住日期';

  @override
  String get labelNights => '晚數';

  @override
  String get labelPeople => '人數';

  @override
  String get labelRooms => '房間數';

  @override
  String get labelRoomType => '房型';

  @override
  String get optionNoSmoking => '禁煙';

  @override
  String get optionSmoking => '吸煙';

  @override
  String get labelTargetPrice => '目標最高價 (¥)';

  @override
  String get hintTargetPrice => '例: 5000，可留空';

  @override
  String sectionHotels(int sel, int total) {
    return '飯店選擇 ($sel/$total)';
  }

  @override
  String get hintHotelSearch => '搜尋飯店名稱或代碼';

  @override
  String get btnSelectAll => '全選';

  @override
  String get btnSelectNone => '全不選';

  @override
  String get sectionControl => '監控控制';

  @override
  String get labelInterval => '查詢間隔';

  @override
  String get labelStopMode => '停止條件';

  @override
  String get stopModeNever => '找到後停止';

  @override
  String get stopModeAttempts => '最多次數';

  @override
  String get stopModeMinutes => '最多分鐘';

  @override
  String get stopModeMatches => '找到N筆停止';

  @override
  String unitSeconds(int sec) {
    return '$sec 秒';
  }

  @override
  String get btnStopMonitor => '停止監控';

  @override
  String get btnStartMonitor => '開始監控';

  @override
  String nextCheckLabel(int sec) {
    return '下次查詢: $sec 秒';
  }

  @override
  String get tabLivePrices => '即時價格';

  @override
  String get tabLog => '日誌';

  @override
  String get tabPriceHistory => '價格歷史';

  @override
  String lastUpdateLabel(String time, int n) {
    return '最後更新: $time（第 $n 次查詢）';
  }

  @override
  String get noDataYet => '尚無資料，請先開始監控';

  @override
  String get columnHotel => '飯店';

  @override
  String get columnLowestPrice => '最低價';

  @override
  String get cantOpenBrowser => '無法開啟瀏覽器';

  @override
  String get noChartData => '尚無資料';

  @override
  String get pageSettingsTitle => '設定';

  @override
  String get sectionAppearance => '外觀';

  @override
  String get themeDark => '深色主題';

  @override
  String get themeLight => '淺色主題';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get sectionLanguage => '語言';

  @override
  String get langZhTW => '繁體中文';

  @override
  String get langJa => '日本語';

  @override
  String get langEn => 'English';

  @override
  String get sectionMatchActions => '找到符合目標價時';

  @override
  String get autoOpenUrlTitle => '自動開啟網頁';

  @override
  String get autoOpenUrlDesc => '找到符合目標價的飯店時，自動在瀏覽器開啟訂房頁面';

  @override
  String get desktopNotifTitle => '桌面通知';

  @override
  String get desktopNotifDesc => '找到符合目標價的飯店時，顯示桌面通知';

  @override
  String get sectionAbout => '關於';

  @override
  String get aboutAppTitle => '東橫 INN 監控器';

  @override
  String get aboutAppSubtitle => '東橫 INN 飯店房價監控工具';

  @override
  String get currentVersion => '版本';

  @override
  String get btnCheckUpdate => '檢查更新';

  @override
  String get updateChecking => '檢查中...';

  @override
  String get updateLatest => '已是最新版本。';

  @override
  String updateAvailable(String version) {
    return '有新版本 $version 可用！';
  }

  @override
  String get btnDownloadUpdate => '立即更新';

  @override
  String get updateDownloading => '正在下載更新...';

  @override
  String get updateLaunchingInstaller => '正在啟動安裝程式...';

  @override
  String get updateInstallerMissing => '找不到此版本的安裝檔。';

  @override
  String get updateCheckFailed => '無法檢查更新。';

  @override
  String get pageTasksTitle => '多任務監控';

  @override
  String get addTaskTooltip => '新增監控任務';

  @override
  String get editTaskTooltip => '修改監控任務';

  @override
  String get noTasksMsg => '尚無監控任務';

  @override
  String get btnAddTask => '新增任務';

  @override
  String get stopTaskTooltip => '停止監控';

  @override
  String get startTaskTooltip => '開始監控';

  @override
  String get deleteTaskTooltip => '刪除任務';

  @override
  String get labelTargetShort => '目標';

  @override
  String get labelLowest => '最低';

  @override
  String get deleteTaskTitle => '刪除任務';

  @override
  String deleteTaskConfirm(String name) {
    return '確定刪除「$name」？';
  }

  @override
  String get btnCancel => '取消';

  @override
  String get btnDelete => '刪除';

  @override
  String get btnSave => '儲存';

  @override
  String get btnAdd => '新增';

  @override
  String get dialogNewTask => '新增監控任務';

  @override
  String get dialogEditTask => '修改監控任務';

  @override
  String get labelTaskName => '任務名稱';

  @override
  String get hintTaskName => '自動產生或自訂';

  @override
  String get noHotelSelected => '請至少選擇一間飯店';

  @override
  String get pageScanTitle => '日期範圍掃描';

  @override
  String get labelCity => '城市';

  @override
  String get labelStartDate => '起始日';

  @override
  String get labelEndDate => '結束日';

  @override
  String get btnStartScan => '開始掃描';

  @override
  String get btnScanning => '掃描中...';

  @override
  String get btnClear => '清除';

  @override
  String get scanHint => '選擇城市和日期範圍後開始掃描，查找最便宜的入住日';

  @override
  String get noValidPrices => '無有效報價';

  @override
  String get scanMinLabel => '最低';

  @override
  String get scanMaxLabel => '最高';

  @override
  String scanDaysCount(int count) {
    return '共掃描 $count 天';
  }

  @override
  String get dashboardNavActiveMonitors => '即時監控';

  @override
  String dashboardPollingEvery(int sec) {
    return '每 $sec 秒輪詢';
  }

  @override
  String get dashboardGlobalAlerts => '全域警報';

  @override
  String get dashboardToggleTheme => '切換主題';

  @override
  String get dashboardThemeLightShort => '淺色';

  @override
  String get dashboardThemeDarkShort => '深色';

  @override
  String get dashboardAddMonitor => '新增監控';

  @override
  String get dashboardRunning => '執行中';

  @override
  String get dashboardPaused => '已暫停';

  @override
  String get dashboardAlert => '警報';

  @override
  String get dashboardLastUpdated => '最後更新';

  @override
  String get dashboardDatabase => '資料庫';

  @override
  String get dashboardConnected => '已連線';

  @override
  String get dashboardPolling => '輪詢';

  @override
  String get dashboardIdle => '待命';

  @override
  String get dashboardMetricLowestPrice => '目前最低價';

  @override
  String get dashboardMetricLowestPriceHelper => '所有啟用監控';

  @override
  String get dashboardMetricTargetHitRate => '目標達成率';

  @override
  String dashboardMetricHitRateHelper(int alerts, int tasks) {
    return '$alerts 個警報 / $tasks 個任務';
  }

  @override
  String get dashboardMetricActiveMonitors => '啟用監控';

  @override
  String dashboardMetricActiveHelper(int running, int paused) {
    return '$running 執行中 / $paused 已暫停';
  }

  @override
  String dashboardTasksCount(int count) {
    return '$count 個任務';
  }

  @override
  String get dashboardNoMonitorTasks => '尚無監控任務';

  @override
  String get dashboardNoMonitorTasksMessage => '新增監控後即可開始追蹤飯店價格。';

  @override
  String get dashboardRefreshView => '重新整理';

  @override
  String get dashboardDeleteMonitorTitle => '刪除監控';

  @override
  String dashboardDeleteMonitorConfirm(String name) {
    return '確定刪除「$name」？';
  }

  @override
  String get dashboardColumnHotelPlan => '飯店 / 方案';

  @override
  String get dashboardColumnStatus => '狀態';

  @override
  String get dashboardColumnVsTarget => '相差目標';

  @override
  String get dashboardColumnLastUpdate => '最後更新';

  @override
  String get dashboardColumnActions => '操作';

  @override
  String dashboardRoomGuestSummary(int rooms, int guests) {
    return '$rooms 間房 / $guests 人';
  }

  @override
  String get dashboardRun => '啟動';

  @override
  String get dashboardPause => '暫停';

  @override
  String get dashboardOpenBooking => '開啟訂房';

  @override
  String get dashboardNotAvailable => '無';

  @override
  String dashboardNights(int count) {
    return '$count 晚';
  }

  @override
  String get dashboardTaskDetails => '任務詳細';

  @override
  String get dashboardCheckOut => '退房日';

  @override
  String get dashboardSelectedHotels => '已選飯店';

  @override
  String get dashboardMatchedRooms => '符合房型';

  @override
  String get dashboardError => '錯誤';

  @override
  String get dashboardPriceTrend => '價格趨勢';

  @override
  String get dashboardLiveMonitor => '即時監控';

  @override
  String dashboardTargetPrice(String price) {
    return '目標 $price';
  }

  @override
  String get dashboardNoTrendData => '尚無趨勢資料';

  @override
  String get dashboardNoTrendDataMessage => '開始輪詢後會繪製即時價格走勢。';

  @override
  String get dashboardDateRangePrices => '日期價格';

  @override
  String get dashboardCheapestCheckinDays => '最便宜入住日';

  @override
  String get dashboardNoScanData => '尚無掃描資料';

  @override
  String get dashboardNoScanDataMessage => '執行日期範圍掃描以比較各日期。';

  @override
  String get dashboardLowestLegend => '最低';

  @override
  String get dashboardNearTarget => '接近目標';

  @override
  String get dashboardHigh => '偏高';

  @override
  String get dashboardLocationDistribution => '地點分布';

  @override
  String get dashboardAllMonitors => '全部監控';

  @override
  String get dashboardNoDistribution => '尚無分布資料';

  @override
  String get dashboardNoDistributionMessage => '建立監控任務後即可查看地點分布。';

  @override
  String get dashboardAlertFeed => '即時警報';

  @override
  String get dashboardRealTime => '即時';

  @override
  String get dashboardNoAlerts => '尚無警報';

  @override
  String get dashboardNoAlertsMessage => '符合目標價與價格警告會顯示在這裡。';

  @override
  String dashboardTargetSuffix(String price) {
    return ' / 目標 $price';
  }

  @override
  String get dashboardPriceAboveTarget => '高於目標價';

  @override
  String get dashboardPriceNearTarget => '接近目標價';

  @override
  String get dashboardTargetHit => '達成目標價';

  @override
  String get dashboardPriceHistory => '價格歷史';

  @override
  String get dashboardStoredPollingResults => '已儲存輪詢結果';

  @override
  String get dashboardMonitorTask => '監控任務';

  @override
  String get dashboardNoTaskSelected => '尚未選擇任務';

  @override
  String get dashboardNoTaskSelectedMessage => '建立監控任務後即可累積歷史資料。';

  @override
  String get dashboardCouldNotLoadHistory => '無法載入歷史資料';

  @override
  String get dashboardNoStoredPrices => '尚無儲存價格';

  @override
  String get dashboardNoStoredPricesMessage => '監控記錄輪詢結果後會顯示歷史資料。';

  @override
  String dashboardHistoryPoints(String code, int count) {
    return '$code  $count 筆';
  }
}
