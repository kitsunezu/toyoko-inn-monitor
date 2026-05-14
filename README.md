# Toyoko Inn Monitor

A Windows desktop application that continuously polls the [Toyoko Inn](https://www.toyoko-inn.com/) API and alerts you the moment a room drops to your target price.

---

## Features

### Live Price Monitor
Set your check-in date, location, number of nights, guests, and room type, then pick a target price ceiling.  
The monitor polls the Toyoko Inn website on a configurable interval (e.g. every 15 seconds) and shows a real-time price table for all selected hotels.

- **Target price matching** — as soon as any hotel hits or goes below your price limit, the monitor can automatically open the booking page in your browser and/or fire a desktop notification.
- **Flexible stop conditions** — run indefinitely, stop on the first match, stop after a fixed number of attempts, a time limit, or after N matches.
- **Live log** — every polling cycle is recorded with timestamps and results for easy review.
- **Price history chart** — a per-session line chart shows how prices have moved across queries.

### Multi-task Monitor
Create and manage multiple independent monitoring tasks at the same time, each with its own search parameters.  
Tasks are persisted in a local SQLite database and resume their state between app sessions.

### Date Range Scan
Scan a range of dates (up to several weeks) for a selected city in a single sweep.  
Results are displayed as a bar chart so you can instantly spot the cheapest nights across the period.

### Settings
- **Theme** — Dark / Light / Follow system.
- **Language** — Traditional Chinese, Japanese, English.
- **On match actions** — toggle auto browser launch and desktop notifications independently.
- **Version & Updates** — shows the current app version and lets you check GitHub Releases for a newer installer with one click.

---

## Installation

Download the latest `ToyokoInnMonitor-x.x.x-setup.exe` from the [Releases](../../releases/latest) page and run the installer.  
No administrator rights are required by default.

### Updating

Open **Settings → About** and click **Check for Updates**.  
If a new version is available, click **Download Update** to open the release page and download the new installer.  
Run the new installer over the existing installation — it will replace the old version automatically.

---

## Building from Source

Requirements: Flutter stable channel, Windows desktop support enabled.

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter build windows --release
```

The compiled app will be in `build\windows\x64\runner\Release\`.

---

## Release / CI

Pushing a tag like `v1.2.3` triggers the GitHub Actions workflow (`.github/workflows/release.yml`) which:

1. Builds the Flutter Windows release.
2. Packages it into a Windows installer using [Inno Setup](https://jrsoftware.org/isinfo.php) (`installer/installer.iss`).
3. Creates a GitHub Release and uploads `ToyokoInnMonitor-1.2.3-setup.exe` as a release asset.

---

## Tech Stack (brief)

| Layer | Technology |
|---|---|
| UI framework | Flutter (Dart) |
| State management | Riverpod |
| Local database | Drift (SQLite) |
| HTTP client | Dio |
| Installer | Inno Setup 6 |
| CI/CD | GitHub Actions |

---

## License

MIT
