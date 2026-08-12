# Toyoko Inn Monitor

<p align="center">
  <a href="README.md">English</a> ｜ <a href="README.zh-TW.md">繁體中文</a> ｜ 日本語
</p>

<p align="center">
  <img src="windows/runner/resources/app_icon_source.png" alt="Toyoko Inn Monitor アイコン" width="120">
</p>

[東横INN](https://www.toyoko-inn.com/) API を継続的に照会し、客室料金が目標価格まで下がったときにすぐ通知する Windows デスクトップアプリです。

---

## 機能

### リアルタイム料金監視

チェックイン日、地域、宿泊数、宿泊人数、部屋タイプを設定し、目標料金の上限を指定します。
設定可能な間隔（例：15 秒ごと）で東横INNのウェブサイトを照会し、選択したすべてのホテルの料金をリアルタイムの一覧で表示します。

- **目標料金との比較** — ホテルの料金が設定額以下になると、予約ページをブラウザーで自動的に開く、デスクトップ通知を送信する、またはその両方を実行できます。
- **柔軟な停止条件** — 無期限での実行、最初の一致、指定回数の照会、制限時間、または N 回の一致後に停止できます。
- **リアルタイムログ** — 照会ごとの時刻と結果を記録し、簡単に確認できます。
- **料金履歴グラフ** — セッションごとの折れ線グラフで、照会間の料金推移を確認できます。

### 複数タスクの監視

それぞれ異なる検索条件を持つ複数の監視タスクを、同時に作成・管理できます。
タスクはローカルの SQLite データベースに保存され、アプリを再起動しても状態が引き継がれます。

### 日付範囲スキャン

選択した都市について、一定の日付範囲（最長数週間）の料金を一度に検索します。
結果は棒グラフで表示され、期間内で最も安い宿泊日をすぐに見つけられます。

### 設定

- **テーマ** — ダーク／ライト／システム設定に従う。
- **言語** — 繁体字中国語、日本語、英語。
- **条件一致時の動作** — ブラウザーの自動起動とデスクトップ通知を個別に切り替えられます。
- **バージョンとアップデート** — 現在のアプリバージョンの表示、GitHub Releases の確認、インストーラー更新の直接ダウンロードができます。

---

## インストール

[Releases](../../releases/latest) ページから最新の Windows パッケージをダウンロードしてください。

- `ToyokoInnMonitor-x.x.x-setup.exe` — インストーラー版。既定では管理者権限は不要です。
- `ToyokoInnMonitor-x.x.x-portable.zip` — ポータブル ZIP 版。展開して `toyoko_inn_monitor.exe` を実行してください。

### アップデート

「**設定 > このアプリについて**」を開き、「**アップデートを確認**」をクリックします。
新しいバージョンがある場合は、「**今すぐアップデート**」をクリックするとインストーラーがダウンロードされ、自動的に起動します。
リリースにインストーラーがない場合は、代わりに Release ページが開きます。

---

## ソースからのビルド

要件：Flutter の stable チャンネル、および Windows デスクトップサポートが有効であること。

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter build windows --release
```

ビルドされたアプリは `build\windows\x64\runner\Release\` に出力されます。

---

## ホテルカタログの同期

選択可能なホテル一覧は、東横INN公式の繁体字中国語版
[ホテル一覧](https://www.toyoko-inn.com/china/hotel_list/) から生成されます。

```powershell
dart run tool/sync_hotels.dart
dart format lib\data\locations.dart tool\sync_hotels.dart test\hotel_catalog_test.dart
dart run tool/sync_hotels.dart --check
```

任意の RAG 形式レビューを行う場合は、同期差分を JSON として出力し、LangChain ヘルパーに渡します。`OPENAI_API_KEY` がない場合、ヘルパーは決定論的な要約を出力し、LLM を呼び出さずに終了します。

```powershell
dart run tool/sync_hotels.dart --check --audit-json tool\hotel_catalog_audit.json
node tool\rag_hotel_audit.mjs --audit-json tool\hotel_catalog_audit.json
```

---

## リリース／CI

`v1.2.3` のようなタグをプッシュすると、GitHub Actions ワークフロー（`.github/workflows/release.yml`）が以下を実行します。

1. Flutter の Windows Release ビルドを作成します。
2. [Inno Setup](https://jrsoftware.org/isinfo.php)（`installer/installer.iss`）を使用して Windows インストーラーをパッケージ化します。
3. 同じ Windows Release フォルダーを `ToyokoInnMonitor-1.2.3-portable.zip` としてパッケージ化します。
4. GitHub Release を作成し、両方の配布ファイルをアップロードします。

---

## 技術スタック（概要）

| レイヤー | 技術 |
|---|---|
| UI フレームワーク | Flutter（Dart） |
| 状態管理 | Riverpod |
| ローカルデータベース | Drift（SQLite） |
| HTTP クライアント | Dio |
| インストーラー | Inno Setup 6 |
| CI/CD | GitHub Actions |

---

## ライセンス

MIT
