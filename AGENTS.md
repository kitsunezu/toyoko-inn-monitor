# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter Windows desktop app for monitoring Toyoko Inn room prices.
Application code lives in `lib/`:

- `lib/main.dart` initializes Flutter, services, database, notifications, and Riverpod overrides.
- `lib/app.dart` owns routing, theme, and localization setup.
- `lib/core/` contains API clients, models, constants, and services.
- `lib/providers/` connects service state to UI through Riverpod.
- `lib/ui/` contains pages, panels, and reusable widgets.
- `lib/data/locations.dart` is generated hotel catalog data.
- `lib/l10n/*.arb` are localization sources; generated localization Dart files should not be hand-edited.

Tests live in `test/`. Windows installer files are in `installer/`, CI workflows in `.github/workflows/`, and utility scripts in `tool/`.

## Build, Test, and Development Commands

Run these from the repository root:

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze --no-fatal-infos
flutter build windows --release
```

Use `dart run tool/sync_hotels.dart` to refresh `lib/data/locations.dart` from the official Toyoko Inn hotel list. Use `dart run tool/sync_hotels.dart --check` in CI or before PRs to verify the generated catalog is current.

## Coding Style & Naming Conventions

Use Dart defaults and run `dart format lib test tool` before submitting changes. Follow Flutter lint guidance from `analysis_options.yaml`. Prefer clear `lowerCamelCase` names for variables and methods, `UpperCamelCase` for classes, and `snake_case.dart` file names. Keep UI text in ARB files instead of hard-coding user-facing strings.

## Testing Guidelines

The project uses `flutter_test`. Add focused tests for utilities, parsers, providers, and generated-data invariants. Name test files with `_test.dart`. Avoid tests that depend on live external APIs unless the command is explicitly an integration check; use fixtures for parser behavior.

## Commit & Pull Request Guidelines

The current history uses Conventional Commit style, for example `feat: initial commit - Toyoko Inn Monitor v1.0.0`. Continue using prefixes such as `feat:`, `fix:`, `test:`, `docs:`, and `chore:`.

PRs should include a concise description, the commands run, any known limitations, and screenshots for visible UI changes. Mention generated files, especially `lib/data/locations.dart`, when they are refreshed.

## Agent-Specific Notes

Do not edit generated files directly: `lib/db/app_database.g.dart`, `lib/l10n/app_localizations*.dart`, and generated hotel catalog output. Change the source schema, ARB files, or sync script instead, then regenerate.

## Overview

Toyoko Inn Monitor is a Flutter Windows desktop app for tracking Toyoko Inn room prices, surfacing match alerts, and publishing downloadable Windows release packages through GitHub Releases. Agents working here should keep Windows-first workflows in mind and make version changes consistently across app metadata, packaging files, release automation, and any UI that displays the current version.

## Project Context

`lib/main.dart` initializes Flutter, SharedPreferences-backed settings, notifications, the Drift database, and Riverpod overrides. `lib/app.dart` owns the shell routes: the focused dashboard is now the `/` landing view, while `/scan` and `/settings` remain top-level destinations and task management is handled through dashboard/task panel flows instead of a dedicated sidebar route.

Runtime monitoring behavior is split between `lib/core/services/` and Riverpod providers in `lib/providers/`. `PollerService`, `tasksProvider`, `pollerProvider`, and dashboard-specific providers keep the active task, recent polling state, alerts, and price history synchronized. Release/update behavior depends on `lib/core/constants.dart`, `lib/core/services/update_service.dart`, and `.github/workflows/release.yml`, so GitHub repository metadata and release asset names must stay aligned.

<!-- commit-and-push-with-agents:context:start -->
### Latest Project Context Signals

- Last scan: `2026-06-14`.
- Review `lib/app.dart` for architecture or project-context updates.
- Review `lib/core/constants.dart` for architecture or project-context updates.
- Review `lib/core/services/settings_service.dart` for architecture or project-context updates.
- Review `lib/core/services/update_service.dart` for architecture or project-context updates.
- Review `lib/l10n/app_en.arb` for architecture or project-context updates.
- Review `lib/l10n/app_ja.arb` for architecture or project-context updates.
- Review `lib/l10n/app_localizations.dart` for architecture or project-context updates.
- Review `lib/l10n/app_localizations_en.dart` for architecture or project-context updates.
- Review `lib/l10n/app_localizations_ja.dart` for architecture or project-context updates.
- Review `lib/l10n/app_localizations_zh.dart` for architecture or project-context updates.
- Review `lib/l10n/app_zh.arb` for architecture or project-context updates.
- Review `lib/providers/tasks_provider.dart` for architecture or project-context updates.
- Review `lib/providers/update_provider.dart` for architecture or project-context updates.
- Review `lib/ui/app_shell.dart` for architecture or project-context updates.
- Review `lib/ui/dashboard/dashboard_charts.dart` for architecture or project-context updates.
- Review `lib/ui/dashboard/dashboard_page.dart` for architecture or project-context updates.
- Review `lib/ui/dashboard/dashboard_style.dart` for architecture or project-context updates.
- Review `lib/ui/dashboard/monitor_task_table.dart` for architecture or project-context updates.
- Review `lib/ui/panels/tasks_panel.dart` for architecture or project-context updates.
- Review `lib/ui/widgets/price_chart.dart` for architecture or project-context updates.
- ... 2 more architecture-related file(s) omitted.
<!-- commit-and-push-with-agents:context:end -->
## Available Features

The app now emphasizes a focused monitoring dashboard with a single highest-priority task, alert feed, history charts, and richer task status presentation. Monitor tasks can run with or without a target price, keep the latest hotel price snapshots, and honor settings-driven browser open and desktop notification behavior.

Release delivery is dual-format: GitHub Releases publish both an installer and a portable ZIP package. The in-app update flow opens the releases page for the user, so release asset naming and repository constants need to match what the workflow uploads.

<!-- commit-and-push-with-agents:features:start -->
### Latest Feature Signals

- Last scan: `2026-06-14`.
- No feature path signal was detected; verify manually from `git diff`.
<!-- commit-and-push-with-agents:features:end -->
## Common Commands

Primary local commands are:

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze --no-fatal-infos
flutter build windows --release
```

If Flutter is not on `PATH`, use `C:\flutter\bin\flutter.bat` and `C:\flutter\bin\cache\dart-sdk\bin\dart.exe`. For a tagged release, bump the app version first, then push a semantic-version tag such as `v1.0.3`; `.github/workflows/release.yml` will publish both `ToyokoInnMonitor-x.y.z-setup.exe` and `ToyokoInnMonitor-x.y.z-portable.zip`.

<!-- commit-and-push-with-agents:commands:start -->
### Latest Command Signals

- Last scan: `2026-06-14`.
- No command path signal was detected; verify manually from `git diff`.
<!-- commit-and-push-with-agents:commands:end -->
## Dependencies & Development Environment

This project targets Flutter/Dart on Windows and uses Riverpod, Drift, Dio, `package_info_plus`, and `shared_preferences` in the runtime. Windows packaging depends on the Flutter Windows release folder and Inno Setup via `installer/installer.iss`, while GitHub Actions handles CI packaging and release uploads.

Do not hand-edit generated localization or Drift outputs. Regenerate from ARB/schema sources, and treat `lib/data/locations.dart` as generated catalog output refreshed by `tool/sync_hotels.dart`.

<!-- commit-and-push-with-agents:environment:start -->
### Latest Dependency and Environment Signals

- Last scan: `2026-06-14`.
- Dependency files: no direct path signal detected.
- Development environment files: no direct path signal detected.
<!-- commit-and-push-with-agents:environment:end -->
## Active Agents

No active agents have been documented yet.

<!-- commit-and-push-with-agents:active:start -->
### Recently Touched Agent Definitions

- Last scan: `2026-06-14`.
- `AGENTS`: `AGENTS.md`.
<!-- commit-and-push-with-agents:active:end -->
## Agent Capabilities & Tools

Agents should keep `AGENTS.md` synchronized with routing, release, and workflow changes. The `commit-and-push-with-agents` skill is the preferred publish workflow when agent documentation should ship with code, but its current Python helper requires an explicit commit message because the default commit-message inference hits a `commands` key mismatch bug.

<!-- commit-and-push-with-agents:capabilities:start -->
### Latest Agent-Related Change Signals

- Last scan: `2026-06-14`.
- `github/workflows/release.yml` (modified)
- `AGENTS.md` (modified)
<!-- commit-and-push-with-agents:capabilities:end -->
## Recent Changes

### 2026-06-14 - Bumped app version for release `v1.0.3`

- Branch: `main`
- Affected files: 4 detected before updating `AGENTS.md`.
- Change types: modified: 4.
- Agent-related files: 1 detected.
- Core impact assessment:
  - Core Architecture: no direct path signal detected.
  - Available Features: no direct path signal detected.
  - Common Commands: review/update required (`AGENTS.md`).
  - Dependencies: no direct path signal detected.
  - Environment: no direct path signal detected.
  - Agent System: no direct path signal detected.
- Files:
  - `AGENTS.md` (modified)
  - `installer/installer.iss` (modified)
  - `pubspec.yaml` (modified)
  - `windows/runner/Runner.rc` (modified)

### 2026-06-14 - Updated agent-facing project context

- Branch: `main`
- Affected files: 31 detected before updating `AGENTS.md`.
- Change types: modified: 30, untracked: 1.
- Agent-related files: 2 detected.
- Core impact assessment:
  - Core Architecture: review/update required (`lib/app.dart`, `lib/core/constants.dart`, `lib/core/services/settings_service.dart`, `lib/core/services/update_service.dart`, `lib/l10n/app_en.arb` and 17 more).
  - Available Features: no direct path signal detected.
  - Common Commands: no direct path signal detected.
  - Dependencies: no direct path signal detected.
  - Environment: no direct path signal detected.
  - Agent System: review/update required (`github/workflows/release.yml`).
- Files:
  - `github/workflows/release.yml` (modified)
  - `AGENTS.md` (modified)
  - `README.md` (modified)
  - `installer/installer.iss` (modified)
  - `lib/app.dart` (modified)
  - `lib/core/constants.dart` (modified)
  - `lib/core/services/settings_service.dart` (modified)
  - `lib/core/services/update_service.dart` (modified)
  - `lib/l10n/app_en.arb` (modified)
  - `lib/l10n/app_ja.arb` (modified)
  - `lib/l10n/app_localizations.dart` (modified)
  - `lib/l10n/app_localizations_en.dart` (modified)
  - `lib/l10n/app_localizations_ja.dart` (modified)
  - `lib/l10n/app_localizations_zh.dart` (modified)
  - `lib/l10n/app_zh.arb` (modified)
  - `lib/providers/tasks_provider.dart` (modified)
  - `lib/providers/update_provider.dart` (modified)
  - `lib/ui/app_shell.dart` (modified)
  - `lib/ui/dashboard/dashboard_charts.dart` (modified)
  - `lib/ui/dashboard/dashboard_page.dart` (modified)
  - `lib/ui/dashboard/dashboard_style.dart` (modified)
  - `lib/ui/dashboard/monitor_task_table.dart` (modified)
  - `lib/ui/panels/tasks_panel.dart` (modified)
  - `lib/ui/widgets/price_chart.dart` (modified)
  - `lib/utils/app_colors.dart` (modified)
  - `lib/utils/app_theme.dart` (modified)
  - `pubspec.yaml` (modified)
  - `test/tasks_provider_test.dart` (modified)
  - `test/widget_test.dart` (modified)
  - `windows/runner/Runner.rc` (modified)
  - `test/update_service_test.dart` (untracked)

### 2026-06-13 - Recorded repository changes

- Branch: `codex/sync-monitor-dashboard`
- Affected files: 4 detected before updating `AGENTS.md`.
- Change types: modified: 4.
- Agent-related files: none detected by path heuristics.
- Core impact assessment:
  - Core Architecture: review/update required (`lib/ui/app_shell.dart`).
  - Available Features: no direct path signal detected.
  - Common Commands: no direct path signal detected.
  - Dependencies: no direct path signal detected.
  - Environment: no direct path signal detected.
  - Agent System: no direct path signal detected.
- Files:
  - `installer/installer.iss` (modified)
  - `lib/ui/app_shell.dart` (modified)
  - `pubspec.yaml` (modified)
  - `windows/runner/Runner.rc` (modified)

### 2026-06-13 - Updated agent-facing project context

- Branch: `codex/sync-monitor-dashboard`
- Affected files: 52 detected before updating `AGENTS.md`.
- Change types: modified: 37, untracked: 15.
- Agent-related files: 7 detected.
- Core impact assessment:
  - Core Architecture: review/update required (`lib/app.dart`, `lib/core/api/toyoko_api.dart`, `lib/core/models/monitor_task.dart`, `lib/core/models/poll_result.dart`, `lib/core/models/search_params.dart` and 37 more).
  - Available Features: review/update required (`lib/ui/pages/live_prices_page.dart`).
  - Common Commands: no direct path signal detected.
  - Dependencies: no direct path signal detected.
  - Environment: no direct path signal detected.
  - Agent System: review/update required (`lib/core/models/monitor_task.dart`, `lib/core/models/poll_result.dart`, `lib/core/models/search_params.dart`, `.github/workflows/hotel-catalog.yml`, `tool/rag_hotel_audit.mjs` and 1 more).
- Files:
  - `gitignore` (modified)
  - `README.md` (modified)
  - `lib/app.dart` (modified)
  - `lib/core/api/toyoko_api.dart` (modified)
  - `lib/core/models/monitor_task.dart` (modified)
  - `lib/core/models/poll_result.dart` (modified)
  - `lib/core/models/search_params.dart` (modified)
  - `lib/core/services/notification_service.dart` (modified)
  - `lib/core/services/poller_service.dart` (modified)
  - `lib/core/services/settings_service.dart` (modified)
  - `lib/data/locations.dart` (modified)
  - `lib/db/app_database.dart` (modified)
  - `lib/l10n/app_en.arb` (modified)
  - `lib/l10n/app_ja.arb` (modified)
  - `lib/l10n/app_localizations.dart` (modified)
  - `lib/l10n/app_localizations_en.dart` (modified)
  - `lib/l10n/app_localizations_ja.dart` (modified)
  - `lib/l10n/app_localizations_zh.dart` (modified)
  - `lib/l10n/app_zh.arb` (modified)
  - `lib/main.dart` (modified)
  - `lib/providers/date_scan_provider.dart` (modified)
  - `lib/providers/poller_provider.dart` (modified)
  - `lib/providers/search_params_provider.dart` (modified)
  - `lib/providers/tasks_provider.dart` (modified)
  - `lib/providers/update_provider.dart` (modified)
  - `lib/ui/app_shell.dart` (modified)
  - `lib/ui/home_page.dart` (modified)
  - `lib/ui/pages/live_prices_page.dart` (modified)
  - `lib/ui/panels/control_panel.dart` (modified)
  - `lib/ui/panels/date_scan_panel.dart` (modified)
  - `lib/ui/panels/results_panel.dart` (modified)
  - `lib/ui/panels/search_panel.dart` (modified)
  - `lib/ui/panels/tasks_panel.dart` (modified)
  - `lib/ui/widgets/price_chart.dart` (modified)
  - `lib/utils/app_colors.dart` (modified)
  - `lib/utils/app_theme.dart` (modified)
  - `test/widget_test.dart` (modified)
  - `.github/workflows/hotel-catalog.yml` (untracked)
  - `AGENTS.md` (untracked)
  - `lib/providers/dashboard_provider.dart` (untracked)
  - `lib/providers/url_launcher_provider.dart` (untracked)
  - `lib/ui/dashboard/alert_feed.dart` (untracked)
  - `lib/ui/dashboard/dashboard_charts.dart` (untracked)
  - `lib/ui/dashboard/dashboard_page.dart` (untracked)
  - `lib/ui/dashboard/dashboard_style.dart` (untracked)
  - `lib/ui/dashboard/metric_card.dart` (untracked)
  - `lib/ui/dashboard/monitor_task_table.dart` (untracked)
  - `test/dashboard_provider_test.dart` (untracked)
  - `test/hotel_catalog_test.dart` (untracked)
  - `test/tasks_provider_test.dart` (untracked)
  - ... 2 more file(s) omitted.
## Architecture Notes

Version changes are cross-cutting in this repo: `pubspec.yaml` drives the runtime version, `windows/runner/Runner.rc` provides the Windows fallback resource version, `installer/installer.iss` controls setup artifact naming, and the shell UI should read the live app version instead of hard-coding a label. Release automation is tag-driven from `.github/workflows/release.yml`, so asset naming or repository metadata changes should be verified against both the workflow and `UpdateService`.

<!-- commit-and-push-with-agents:architecture:start -->
### Latest Change Footprint

- Last scan: `2026-06-14`.
- Most affected areas: `lib` (22), `test` (3), `github` (1), `AGENTS.md` (1), `README.md` (1), `installer` (1), `pubspec.yaml` (1), `windows` (1).
<!-- commit-and-push-with-agents:architecture:end -->
