# InkScroller — Flutter Mobile Client

> A full-featured manga reader app built with Flutter, Clean Architecture, and Firebase. Personal portfolio project by **Mercedes Franchesca Gonzalez Cejas** (MGC Studio).

![Flutter](https://img.shields.io/badge/Flutter-3.41.5-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Analytics-FFCA28?logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-2.6.1-00B4D8?logo=dart&logoColor=white)
![Tests](https://img.shields.io/badge/tests-169%20passing-brightgreen)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white)
![License](https://img.shields.io/badge/license-proprietary-lightgrey)

---

## What is InkScroller?

InkScroller is a manga discovery and reading app that lets users browse a curated catalog, save titles to a personal library, and read chapters in a fully customizable reader.

The app connects to a custom [Python/FastAPI backend](https://github.com/mfranchescagonzalezcejas/inkscroller-api) that proxies MangaDex and Jikan for catalog and metadata, and exposes user-specific endpoints for library management, preferences, and reading progress.

This repository is the **Flutter mobile client**. It targets Android (3 flavors: dev/staging/pro) with a CI/CD pipeline that builds and distributes via Firebase App Distribution and creates GitHub Releases automatically on tag push.

---

## Features

| Area | Details |
|------|---------|
| **Home** | Curated sections (Featured, Latest, Popular) with cover precaching and demographic tabs |
| **Library** | Responsive grid with progressive loading, debounced search, infinite scroll, and background sync indicator |
| **User Library** | Save/remove titles, track reading status (added / reading / completed / paused), synced with backend |
| **Reading Progress** | Per-chapter progress tracked locally and synced to backend; preloaded on startup |
| **Manga Detail** | Cover, metadata, chapter list, per-title reader mode override |
| **Adaptive Reader** | Vertical-scroll and paged modes; direction auto-resolved via per-title override → global preference → content heuristic → default |
| **Reader Settings** | Brightness, reading direction, AMOLED mode, immersive mode — live in-reader panel |
| **Auth** | Firebase email/password sign-in/sign-up, route guard, JWT auth interceptor on every request |
| **Profile & Preferences** | Account info, global reading preferences, app locale (ES/EN), independent from reading language |
| **Offline** | Connectivity banner on key content screens; preferences remain accessible when profile fetch fails |
| **Flavors** | `dev` / `staging` / `pro` with distinct icons, flavor banners, and Cloud Run endpoints via `--dart-define` |

---

## Architecture

**Screaming Architecture** (outer structure) + **Clean Architecture** (inner layers), applied pragmatically.

```
lib/
├── features/
│   ├── auth/          # Firebase auth, route guard, JWT interceptor
│   ├── home/          # Curated sections, cover precaching
│   ├── library/       # Catalog browsing, user library, reader, reading progress
│   ├── profile/       # User account, preferences
│   ├── settings/      # App-level settings
│   └── about/         # Attribution, version info
└── core/
    ├── di/            # get_it service locator wiring
    ├── router/        # go_router with auth guards
    ├── theme/         # Design tokens, light/dark
    ├── config/        # Environment, flavor detection
    └── l10n/          # Localization (ES/EN)
```

Each feature follows a strict 3-layer boundary:

| Layer | Responsibility |
|-------|---------------|
| **Presentation** | Riverpod `StateNotifierProvider`, pages, widgets. Reads use cases from `get_it`. No Dio, no Firebase. |
| **Domain** | Pure Dart entities, repository contracts, use cases. Zero Flutter dependencies. |
| **Data** | Implements repository contracts: JSON models, mappers, Dio datasources, SharedPreferences. |

The domain layer owns the contracts — data and presentation layers depend on it, never on each other.

> Full architecture details: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

---

## Tech Stack

| Concern | Library / Approach |
|---------|-------------------|
| UI Framework | Flutter 3.41.5 (FVM-pinned) |
| State Management | flutter_riverpod `^2.6.1` — `StateNotifierProvider` for mutable state |
| Dependency Injection | get_it `^7.6.7` — service locator wired at app startup |
| Navigation | go_router `^14.8.1` — `StatefulShellRoute` for persistent bottom nav |
| HTTP Client | Dio `^5.x` — 60 s timeout for Cloud Run cold starts, auth interceptor |
| Authentication | firebase_auth `^6.1.4` — email/password, ID token on every request |
| Local Persistence | shared_preferences `^2.5.3` |
| Connectivity | connectivity_plus `^6.1.5` |
| Image Caching | cached_network_image — 7-day TTL |
| Analytics | firebase_analytics `^12.1.1` |

> Full dependency list: [`pubspec.yaml`](pubspec.yaml)

---

## CI/CD Pipeline

Automated via GitHub Actions with two workflows:

**CI** (`ci.yml`) — triggered on PRs to `develop` / `master` and pushes to `develop`:
- Static analysis (`flutter analyze`)
- Unit tests — core, domain, data, providers
- UI tests — pages and widgets (informational, non-blocking)

**Release** (`release.yml`) — triggered on version tags (`v*.*.*`) or manual dispatch:
1. Quality gates (analyze + all tests + tag/pubspec version match)
2. Build APK matrix: dev · staging · pro (parallel)
3. Create GitHub Release with auto-generated changelog
4. Distribute to Firebase App Distribution testers (per flavor)

```
tag push v0.6.0
    └─▶ quality-gates ──▶ build-apk (×3) ──▶ GitHub Release ──▶ Firebase Distribute (×3)
```

---

## Getting Started

### Prerequisites

- [FVM](https://fvm.app) — the project pins **Flutter 3.41.5** via `.fvmrc`
- Android Studio or VS Code with Flutter plugin
- A Firebase project with `google-services.json` placed in `android/app/src/<flavor>/`
- The [InkScroller backend](https://github.com/mfranchescagonzalezcejas/inkscroller-api) running locally or via Cloud Run

### Install & Run

```bash
# Install pinned Flutter version
fvm install

# Install dependencies
fvm flutter pub get

# Run dev flavor on emulator
fvm flutter run -t lib/main_dev.dart --flavor dev

# Run dev flavor on physical device via Cloud Run
fvm flutter run -d <device-id> -t lib/main_dev.dart --flavor dev \
  --dart-define=API_BASE_URL=https://inkscroller-backend-708894048002.us-central1.run.app \
  --dart-define-from-file=.dart-defines/firebase.json
```

Firebase dart-defines go in `.dart-defines/firebase.json` (see `.dart-defines/firebase.example.json` for the required keys). This file is git-ignored — never commit it.

### Run Configurations

Android Studio run configs are committed in `.run/`. Select `Flutter <Flavor> Physical (Cloud Run)` to run against the deployed backend.

VS Code equivalents are in `.vscode/launch.json`.

---

## Testing

```bash
# All tests
fvm flutter test

# Unit tests only (core + domain + data + providers)
fvm flutter test test/core/ test/features/*/domain/ test/features/*/data/ test/features/*/presentation/providers/

# UI tests
fvm flutter test test/features/*/presentation/pages/ test/features/*/presentation/widgets/
```

169 tests covering: auth flow, user library, reading progress, reader mode resolution, router guards, preferences, and compliance.

---

## API

The app consumes the [InkScroller Backend](https://github.com/mfranchescagonzalezcejas/inkscroller-api). Every request attaches a Firebase ID token via `AuthInterceptor`.

| Method | Endpoint | Description |
|--------|---------|-------------|
| `GET` | `/manga` | Paginated manga catalog |
| `GET` | `/manga/search` | Title search |
| `GET` | `/manga/{id}` | Manga detail (MangaDex + Jikan enrichment) |
| `GET` | `/chapters/manga/{id}` | Chapter list |
| `GET` | `/chapters/{id}/pages` | Page image URLs |
| `GET` | `/users/me` | Authenticated user profile |
| `GET/PUT` | `/users/me/preferences` | Reading preferences |
| `GET/POST/DELETE` | `/users/me/library` | User library management |
| `GET/POST` | `/users/me/reading-progress` | Per-chapter reading progress |

> Full integration details: [`docs/API_INTEGRATION.md`](docs/API_INTEGRATION.md)

---

## Flavors

| Flavor | Entry point | Banner | Purpose |
|--------|------------|--------|---------|
| `dev` | `main_dev.dart` | 🔴 DEV | Local development, hot reload |
| `staging` | `main_staging.dart` | 🟠 STAGING | Pre-release QA |
| `pro` | `main_pro.dart` | _(none)_ | Production-equivalent |

Each flavor has its own Firebase project, `google-services.json`, and Cloud Run endpoint.

---

## Project Structure (key files)

```
inkscroller-mobile/
├── lib/
│   ├── main_dev.dart / main_staging.dart / main_pro.dart   # Flavor entry points
│   ├── firebase_options.dart                                # Env-based Firebase config (dart-define)
│   └── features/library/
│       ├── domain/entities/user_library_entry.dart          # User library entity
│       ├── data/datasources/user_library_remote_ds_impl.dart
│       └── presentation/providers/user_library_provider.dart
├── test/                    # 169 tests
├── .github/workflows/       # CI + Release pipeline
├── .run/                    # Android Studio run configs
├── .dart-defines/           # Firebase dart-define templates (secrets git-ignored)
└── docs/                    # Architecture, API, CI, release docs
```

---

## Attribution & Legal

InkScroller displays aggregated content from external sources through its backend proxy:

- **MangaDex** — primary source for manga catalog, chapter, and image data. InkScroller is not affiliated with MangaDex. Content belongs to its respective authors and scanlation groups. [Terms of Service](https://mangadex.org/about/terms-of-service) apply.
- **Jikan / MyAnimeList** — metadata enrichment (score, rank, genres). Jikan is an unofficial third-party service. InkScroller is not affiliated with MyAnimeList or Jikan.

The Flutter client does not call MangaDex or Jikan directly — every request goes through the InkScroller backend, which acts as a read-only proxy. InkScroller does not store or redistribute content in bulk.

> See [`docs/legal/api-compliance.md`](docs/legal/api-compliance.md) for full compliance details.

---

## License

Source-available / proprietary.

Copyright © 2026 Mercedes Franchesca Gonzalez Cejas — All rights reserved.

See [`LICENSE`](LICENSE) for terms.
