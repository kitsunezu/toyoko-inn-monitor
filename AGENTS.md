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

Summarize the repository purpose and the agent-facing context future contributors should know.

## Project Context

Document core architecture, project purpose, and important implementation context here.

<!-- commit-and-push-with-agents:context:start -->
### Latest Project Context Signals

- Last scan: `2026-06-13`.
- Review `lib/app.dart` for architecture or project-context updates.
- Review `lib/core/api/toyoko_api.dart` for architecture or project-context updates.
- Review `lib/core/models/monitor_task.dart` for architecture or project-context updates.
- Review `lib/core/models/poll_result.dart` for architecture or project-context updates.
- Review `lib/core/models/search_params.dart` for architecture or project-context updates.
- Review `lib/core/services/notification_service.dart` for architecture or project-context updates.
- Review `lib/core/services/poller_service.dart` for architecture or project-context updates.
- Review `lib/core/services/settings_service.dart` for architecture or project-context updates.
- Review `lib/data/locations.dart` for architecture or project-context updates.
- Review `lib/db/app_database.dart` for architecture or project-context updates.
- Review `lib/l10n/app_en.arb` for architecture or project-context updates.
- Review `lib/l10n/app_ja.arb` for architecture or project-context updates.
- Review `lib/l10n/app_localizations.dart` for architecture or project-context updates.
- Review `lib/l10n/app_localizations_en.dart` for architecture or project-context updates.
- Review `lib/l10n/app_localizations_ja.dart` for architecture or project-context updates.
- Review `lib/l10n/app_localizations_zh.dart` for architecture or project-context updates.
- Review `lib/l10n/app_zh.arb` for architecture or project-context updates.
- Review `lib/main.dart` for architecture or project-context updates.
- Review `lib/providers/date_scan_provider.dart` for architecture or project-context updates.
- Review `lib/providers/poller_provider.dart` for architecture or project-context updates.
- ... 22 more architecture-related file(s) omitted.
<!-- commit-and-push-with-agents:context:end -->
## Available Features

Document user-facing or agent-facing features here as they are added or changed.

<!-- commit-and-push-with-agents:features:start -->
### Latest Feature Signals

- Last scan: `2026-06-13`.
- Review `lib/ui/pages/live_prices_page.dart` for user-facing or agent-facing feature updates.
<!-- commit-and-push-with-agents:features:end -->
## Common Commands

Document build, test, lint, run, and release commands here.

<!-- commit-and-push-with-agents:commands:start -->
### Latest Command Signals

- Last scan: `2026-06-13`.
- No command path signal was detected; verify manually from `git diff`.
<!-- commit-and-push-with-agents:commands:end -->
## Dependencies & Development Environment

Document dependency managers, runtime versions, setup steps, and development environment assumptions here.

<!-- commit-and-push-with-agents:environment:start -->
### Latest Dependency and Environment Signals

- Last scan: `2026-06-13`.
- Dependency files: no direct path signal detected.
- Development environment files: no direct path signal detected.
<!-- commit-and-push-with-agents:environment:end -->
## Active Agents

No active agents have been documented yet.

<!-- commit-and-push-with-agents:active:start -->
### Recently Touched Agent Definitions

- Last scan: `2026-06-13`.
- `AGENTS`: `AGENTS.md`.
<!-- commit-and-push-with-agents:active:end -->
## Agent Capabilities & Tools

Document agent capabilities, tools, prompts, skills, and workflows here.

<!-- commit-and-push-with-agents:capabilities:start -->
### Latest Agent-Related Change Signals

- Last scan: `2026-06-13`.
- `lib/core/models/monitor_task.dart` (modified)
- `lib/core/models/poll_result.dart` (modified)
- `lib/core/models/search_params.dart` (modified)
- `.github/workflows/hotel-catalog.yml` (untracked)
- `AGENTS.md` (untracked)
- `tool/rag_hotel_audit.mjs` (untracked)
- `tool/sync_hotels.dart` (untracked)
<!-- commit-and-push-with-agents:capabilities:end -->
## Recent Changes

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

Document architecture decisions and integration notes relevant to agents here.

<!-- commit-and-push-with-agents:architecture:start -->
### Latest Change Footprint

- Last scan: `2026-06-13`.
- Most affected areas: `lib` (42), `test` (4), `tool` (2), `gitignore` (1), `README.md` (1), `.github` (1), `AGENTS.md` (1).
<!-- commit-and-push-with-agents:architecture:end -->
