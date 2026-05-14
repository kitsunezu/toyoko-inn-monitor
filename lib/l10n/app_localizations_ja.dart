// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '東横イン モニター';

  @override
  String get navMonitor => '監視';

  @override
  String get navTasks => 'タスク';

  @override
  String get navScan => 'スキャン';

  @override
  String get navSettings => '設定';

  @override
  String get tabSearch => '検索設定';

  @override
  String get tabResults => '結果';

  @override
  String get sectionSearch => '検索条件';

  @override
  String get labelLocation => '場所';

  @override
  String get labelCheckin => 'チェックイン日';

  @override
  String get labelNights => '泊数';

  @override
  String get labelPeople => '人数';

  @override
  String get labelRooms => '部屋数';

  @override
  String get labelRoomType => '客室タイプ';

  @override
  String get optionNoSmoking => '禁煙';

  @override
  String get optionSmoking => '喫煙';

  @override
  String get labelTargetPrice => '目標最高価格 (¥)';

  @override
  String get hintTargetPrice => '例: 5000';

  @override
  String sectionHotels(int sel, int total) {
    return 'ホテル選択 ($sel/$total)';
  }

  @override
  String get hintHotelSearch => 'ホテル名またはコードを検索';

  @override
  String get btnSelectAll => 'すべて選択';

  @override
  String get btnSelectNone => 'すべて解除';

  @override
  String get sectionControl => '監視コントロール';

  @override
  String get labelInterval => '検索間隔';

  @override
  String get labelStopMode => '停止条件';

  @override
  String get stopModeNever => '見つかったら停止';

  @override
  String get stopModeAttempts => '最大回数';

  @override
  String get stopModeMinutes => '最大分数';

  @override
  String get stopModeMatches => 'N件で停止';

  @override
  String unitSeconds(int sec) {
    return '$sec 秒';
  }

  @override
  String get btnStopMonitor => '監視停止';

  @override
  String get btnStartMonitor => '監視開始';

  @override
  String nextCheckLabel(int sec) {
    return '次回検索: $sec 秒';
  }

  @override
  String get tabLivePrices => 'リアルタイム価格';

  @override
  String get tabLog => 'ログ';

  @override
  String get tabPriceHistory => '価格履歴';

  @override
  String lastUpdateLabel(String time, int n) {
    return '最終更新: $time（第 $n 回目）';
  }

  @override
  String get noDataYet => 'データなし。まず監視を開始してください';

  @override
  String get columnHotel => 'ホテル';

  @override
  String get columnLowestPrice => '最安値';

  @override
  String get cantOpenBrowser => 'ブラウザを開けません';

  @override
  String get noChartData => 'データなし';

  @override
  String get pageSettingsTitle => '設定';

  @override
  String get sectionAppearance => '外観';

  @override
  String get themeDark => 'ダークテーマ';

  @override
  String get themeLight => 'ライトテーマ';

  @override
  String get themeSystem => 'システムに従う';

  @override
  String get sectionLanguage => '言語';

  @override
  String get langZhTW => '繁體中文';

  @override
  String get langJa => '日本語';

  @override
  String get langEn => 'English';

  @override
  String get sectionMatchActions => '目標価格一致時';

  @override
  String get autoOpenUrlTitle => '自動的にWebページを開く';

  @override
  String get autoOpenUrlDesc => '目標価格に合うホテルが見つかったとき、ブラウザで予約ページを自動的に開く';

  @override
  String get desktopNotifTitle => 'デスクトップ通知';

  @override
  String get desktopNotifDesc => '目標価格に合うホテルが見つかったとき、デスクトップ通知を表示する';

  @override
  String get sectionAbout => 'このアプリについて';

  @override
  String get aboutAppTitle => '東横イン モニター';

  @override
  String get aboutAppSubtitle => '東横イン 客室料金モニターツール';

  @override
  String get currentVersion => 'バージョン';

  @override
  String get btnCheckUpdate => 'アップデートを確認';

  @override
  String get updateChecking => '確認中...';

  @override
  String get updateLatest => '最新バージョンです。';

  @override
  String updateAvailable(String version) {
    return '新バージョン $version が利用可能です！';
  }

  @override
  String get btnDownloadUpdate => 'アップデートをダウンロード';

  @override
  String get updateCheckFailed => 'アップデートの確認に失敗しました。';

  @override
  String get pageTasksTitle => 'マルチタスク監視';

  @override
  String get addTaskTooltip => '監視タスクを追加';

  @override
  String get noTasksMsg => '監視タスクなし';

  @override
  String get btnAddTask => 'タスクを追加';

  @override
  String get stopTaskTooltip => '監視停止';

  @override
  String get startTaskTooltip => '監視開始';

  @override
  String get deleteTaskTooltip => 'タスクを削除';

  @override
  String get labelTargetShort => '目標';

  @override
  String get labelLowest => '最安値';

  @override
  String get deleteTaskTitle => 'タスクを削除';

  @override
  String deleteTaskConfirm(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get btnCancel => 'キャンセル';

  @override
  String get btnDelete => '削除';

  @override
  String get btnAdd => '追加';

  @override
  String get dialogNewTask => '監視タスクを追加';

  @override
  String get labelTaskName => 'タスク名';

  @override
  String get hintTaskName => '自動生成または手動入力';

  @override
  String get noHotelSelected => 'ホテルを少なくとも1つ選択してください';

  @override
  String get pageScanTitle => '日付範囲スキャン';

  @override
  String get labelCity => '都市';

  @override
  String get labelStartDate => '開始日';

  @override
  String get labelEndDate => '終了日';

  @override
  String get btnStartScan => 'スキャン開始';

  @override
  String get btnScanning => 'スキャン中...';

  @override
  String get btnClear => 'クリア';

  @override
  String get scanHint => '都市と日付範囲を選択してスキャンを開始し、最安値の宿泊日を検索します';

  @override
  String get noValidPrices => '有効な料金なし';

  @override
  String get scanMinLabel => '最安値';

  @override
  String get scanMaxLabel => '最高値';

  @override
  String scanDaysCount(int count) {
    return '$count日間スキャン済み';
  }
}
