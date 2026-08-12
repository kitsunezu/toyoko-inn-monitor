# Toyoko Inn Monitor

<p align="center">
  <a href="README.md">English</a> ｜ 繁體中文 ｜ <a href="README.ja.md">日本語</a>
</p>

<p align="center">
  <img src="windows/runner/resources/app_icon_source.png" alt="Toyoko Inn Monitor 圖示" width="120">
</p>

這是一款 Windows 桌面應用程式，會持續查詢 [Toyoko Inn](https://www.toyoko-inn.com/) API，並在客房價格降至你的目標價時立即通知你。

---

## 功能

### 即時價格監控

設定入住日期、地點、住宿晚數、入住人數及房型，再指定目標價格上限。
監控器會依照可調整的間隔（例如每 15 秒）查詢 Toyoko Inn 網站，並即時顯示所有已選飯店的價格表。

- **目標價格比對** — 任何飯店價格達到或低於設定上限時，監控器可自動在瀏覽器中開啟訂房頁面及／或發送桌面通知。
- **彈性的停止條件** — 可持續執行，或在首次符合條件、固定查詢次數、時間限制或符合 N 次條件後停止。
- **即時記錄** — 每次查詢都會記錄時間與結果，方便日後檢視。
- **價格歷史圖表** — 每次監控工作階段都有折線圖，呈現各次查詢間的價格變化。

### 多工作監控

可同時建立及管理多個獨立的監控工作，每個工作都有各自的搜尋條件。
工作會儲存在本機 SQLite 資料庫，重新開啟應用程式後仍會保留原有狀態。

### 日期範圍掃描

一次掃描所選城市在一段日期範圍內（最長數週）的房價。
結果會以長條圖顯示，讓你快速找出這段期間最便宜的住宿日期。

### 設定

- **主題** — 深色／淺色／跟隨系統。
- **語言** — 繁體中文、日文、英文。
- **符合條件時的動作** — 可分別啟用自動開啟瀏覽器及桌面通知。
- **版本與更新** — 顯示目前的應用程式版本、檢查 GitHub Releases，並直接下載安裝程式更新。

---

## 安裝

請從 [Releases](../../releases/latest) 頁面下載最新的 Windows 套件：

- `ToyokoInnMonitor-x.x.x-setup.exe` — 安裝版，預設不需要系統管理員權限。
- `ToyokoInnMonitor-x.x.x-portable.zip` — 可攜式 ZIP 版，解壓縮後執行 `toyoko_inn_monitor.exe`。

### 更新

開啟「**設定 > 關於**」，然後按一下「**檢查更新**」。
若有新版本，按一下「**立即更新**」即可下載安裝程式並自動啟動。
若該版本沒有安裝程式檔案，應用程式會改為開啟 Release 頁面。

---

## 從原始碼建置

需求：Flutter stable 頻道，並已啟用 Windows 桌面支援。

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter build windows --release
```

編譯完成的應用程式位於 `build\windows\x64\runner\Release\`。

---

## 飯店目錄同步

可選飯店清單是根據 Toyoko Inn 官方繁體中文
[飯店一覽](https://www.toyoko-inn.com/china/hotel_list/) 產生。

```powershell
dart run tool/sync_hotels.dart
dart format lib\data\locations.dart tool\sync_hotels.dart test\hotel_catalog_test.dart
dart run tool/sync_hotels.dart --check
```

若要進行選用的 RAG 式檢查，請將同步差異輸出為 JSON，再交給 LangChain 輔助工具處理。若未設定 `OPENAI_API_KEY`，輔助工具只會輸出固定格式的摘要，不會呼叫 LLM。

```powershell
dart run tool/sync_hotels.dart --check --audit-json tool\hotel_catalog_audit.json
node tool\rag_hotel_audit.mjs --audit-json tool\hotel_catalog_audit.json
```

---

## 發布／CI

推送 `v1.2.3` 這類標籤後，GitHub Actions 工作流程（`.github/workflows/release.yml`）會：

1. 建置 Flutter Windows Release 版本。
2. 使用 [Inno Setup](https://jrsoftware.org/isinfo.php)（`installer/installer.iss`）封裝 Windows 安裝程式。
3. 將同一個 Windows Release 資料夾封裝為 `ToyokoInnMonitor-1.2.3-portable.zip`。
4. 建立 GitHub Release 並上傳兩種發行檔案。

---

## 技術架構（摘要）

| 層級 | 技術 |
|---|---|
| UI 框架 | Flutter（Dart） |
| 狀態管理 | Riverpod |
| 本機資料庫 | Drift（SQLite） |
| HTTP 用戶端 | Dio |
| 安裝程式 | Inno Setup 6 |
| CI/CD | GitHub Actions |

---

## 授權條款

MIT
