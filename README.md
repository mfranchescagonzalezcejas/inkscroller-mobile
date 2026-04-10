# 📖 InkScroller — MGC Studio

> Portfolio-ready Flutter manga reader focused on clean architecture, adaptive reading flows, and end-to-end product thinking.

> Built and presented by **MGC Studio** — the portfolio identity of Mercedes Franchesca Gonzalez Cejas.

![Flutter](https://img.shields.io/badge/Flutter-3.41.5-02569B?logo=flutter&logoColor=white)
![FVM](https://img.shields.io/badge/FVM-managed-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Analytics-FFCA28?logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-2.6.1-00B4D8?logo=dart&logoColor=white)
![Tests](https://img.shields.io/badge/tests-149%20passing-brightgreen)
![License](https://img.shields.io/badge/license-proprietary-lightgrey)

---

## ✨ Features

| Area | What's included |
|------|----------------|
| **Home** | Curated sections (Featured, Latest, Popular) + demographic tabs |
| **Library** | Responsive masonry grid, debounced search, infinite scroll |
| **Manga detail** | Cover, metadata, chapter list, per-title reader mode override |
| **Adaptive reader** | Vertical-scroll and paged modes; auto-resolved via per-title override → global preference → content heuristic → default |
| **Auth** | Firebase email/password sign-in/sign-up, route guard, auth interceptor |
| **Profile** | Account info, global reading preferences (reader mode + language), sign-out |
| **Preferences** | Local-first with SharedPreferences fallback; offline conflict resolution via timestamp comparison |
| **Offline** | Connectivity banner on key content screens (Library, Explore, Manga Detail); preferences remain accessible when profile fetch fails |
| **Flavors** | `dev` / `staging` / `pro` with distinct icons and flavor banners; environment endpoints are configured via run configs / `--dart-define` |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.41.5 (FVM) |
| State Management | flutter_riverpod `^2.6.1` |
| Dependency Injection | get_it `^7.6.7` |
| HTTP Client | dio `^5.x` (60 s timeout for Cloud Run cold starts) |
| Authentication | firebase_auth `^6.1.4` |
| Local persistence | shared_preferences `^2.5.3` |
| Connectivity | connectivity_plus `^6.1.5` |
| Image Caching | cached_network_image (7-day TTL) |
| Analytics | firebase_analytics `^12.1.1` |
| Navigation | go_router `^14.8.1` |

> Full dependency list: [`pubspec.yaml`](pubspec.yaml)

---

## 🚀 Getting Started

### Prerequisites

- [FVM](https://fvm.app) — the project pins **Flutter 3.41.5** via `.fvmrc`
- Android Studio or VS Code with Flutter plugin
- Firebase project — place `google-services.json` in `android/app/src/<flavor>/`

### Install & Run

```bash
# Install pinned Flutter version
fvm install

# Install dependencies
fvm flutter pub get

# Run dev flavor (emulator)
fvm flutter run -t lib/main_dev.dart --flavor dev

# Run dev flavor on physical device via Cloud Run
fvm flutter run -d <device-id> -t lib/main_dev.dart --flavor dev \
  --dart-define=API_BASE_URL=https://inkscroller-backend-708894048002.us-central1.run.app
```

> See [`docs/ANDROID_STUDIO_SETUP.md`](docs/ANDROID_STUDIO_SETUP.md) for shared run configs and bootstrap script.  
> See [`docs/PHYSICAL_DEVICE.md`](docs/PHYSICAL_DEVICE.md) for physical device setup.

### Important for public users

This repository is a **public showcase copy**.

- It is meant to be readable, runnable, and portfolio-friendly.
- Sensitive files such as Firebase config stay **local-only** and are ignored by git.
- Some internal release/distribution automation from the private repo is intentionally excluded here.
- `lib/firebase_options.dart` in this public repo is sanitized for showcase purposes and expects environment-injected values.

---

## 🎭 Flavors & Environments

| Flavor | Entry point | Banner | Endpoint config |
|--------|------------|--------|----------------|
| `dev` | `main_dev.dart` | 🔴 DEV | configured per environment via run configs / `--dart-define` |
| `staging` | `main_staging.dart` | 🟠 STAGING | configured per environment via run configs / `--dart-define` |
| `pro` | `main_pro.dart` | none | configured per environment via run configs / `--dart-define` |

Run configs (`.run/`) are committed — select `Flutter <Flavor> Physical (Cloud Run)` in Android Studio.

---

## 🏛️ Architecture

**Screaming Architecture** (outer) + **Clean Architecture** (inner), implemented pragmatically for Flutter.

- `features/` is organized by business domain — each directory screams what the app does, not what framework it uses.
- Inside each feature, layer boundaries are enforced by convention and are currently being refined as the structure evolves: `Presentation → Domain ← Data`.

| Layer | Role |
|-------|------|
| **Presentation** | Riverpod `StateNotifierProvider` + pages + widgets. Reads use cases from `get_it`. |
| **Domain** | Pure Dart entities, repository contracts, use cases. No Flutter, no Dio. |
| **Data** | Implements repository contracts. JSON models, mappers, Dio datasources. |

Features: `auth` · `library` · `explore` · `home` · `preferences` · `profile` · `navigation` · `settings` · `about`

> Full architecture details: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

### Why this project matters

This project is part of my portfolio to demonstrate:

- Flutter app architecture beyond toy examples
- feature-based organization with clear domain boundaries
- adaptive reading UX and product-oriented thinking
- integration between mobile client, auth, and backend APIs

---

## 📡 API

The app consumes the [InkScroller Backend](https://github.com/mfranchescagonzalezcejas/Inkscroller_backend). Every request attaches a Firebase ID token via `AuthInterceptor`.

| Method | Endpoint | Description |
|--------|---------|-------------|
| `GET` | `/manga` | Paginated manga list |
| `GET` | `/manga/search` | Title search (max 5 results) |
| `GET` | `/manga/{id}` | Manga detail (MangaDex + Jikan enrichment) |
| `GET` | `/chapters/manga/{id}` | Chapter list |
| `GET` | `/chapters/{id}/pages` | Page image URLs |
| `GET` | `/users/me` | Authenticated user profile |
| `GET` | `/users/me/preferences` | Reading preferences |
| `PUT` | `/users/me/preferences` | Update reading preferences |

> Full integration details: [`docs/API_INTEGRATION.md`](docs/API_INTEGRATION.md)

---

## 🧭 Navigation

4-tab `StatefulShellRoute` (Home · Explore · Library · Profile) + pushed detail routes:

| Route | Widget |
|-------|--------|
| `/` | `HomePage` |
| `/explore` | `ExplorePage` |
| `/library` | `LibraryPage` |
| `/profile` | `ProfilePage` |
| `/settings` | `SettingsPage` |
| `/manga/:id` | `MangaDetailPage` |
| `/manga/:id/chapter/:id` | `ReaderPage` |
| `/login` · `/register` | Auth pages |

---

## 🧪 Testing

```bash
# All tests
fvm flutter test

# Unit tests only (core + domain + data + providers)
fvm flutter test test/core test/features --exclude-tags ui
```

149 tests currently passing across auth, preferences, profile, reader, router, and compliance-related flows.

> Public repo includes CI checks for analyze + tests. Internal release/distribution automation remains private.

---

## 📄 More Docs

| Document | Description |
|---------|-------------|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Full architecture, DI graph, Riverpod strategy |
| [`docs/API_INTEGRATION.md`](docs/API_INTEGRATION.md) | API contracts and integration details |
| [`docs/ANDROID_STUDIO_SETUP.md`](docs/ANDROID_STUDIO_SETUP.md) | Run configs, bootstrap script |
| [`docs/PHYSICAL_DEVICE.md`](docs/PHYSICAL_DEVICE.md) | Physical device setup over LAN and Cloud Run |
| [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) | Current sprint status and implementation reality |
| [`docs/PRD.md`](docs/PRD.md) | Product requirements |

---

## 👩‍💻 Portfolio context

InkScroller is part of my mobile/software engineering portfolio.

It highlights work on:

- Flutter + Riverpod application structure
- feature-based modularization
- Firebase Auth integration
- backend-driven reading flows
- documentation and architectural discipline

## 🪪 Brand

**MGC Studio** is the public-facing identity used for portfolio presentation, technical projects, and product-oriented development work.

- **Brand:** MGC Studio
- **Author:** Mercedes Franchesca Gonzalez Cejas
- **Focus:** mobile apps, software engineering, architecture, and product-driven builds

---

## ⚖️ Attribution and Disclaimer

InkScroller displays aggregated content from the following external sources through its backend proxy:

- **MangaDex** — primary source for manga catalog, chapter, and image data. InkScroller is not affiliated with MangaDex. Content belongs to its respective authors and scanlation groups. MangaDex [Terms of Service](https://mangadex.org/about/terms-of-service) apply.
- **Jikan / MyAnimeList** — metadata enrichment source (score, rank, genres). Jikan is an unofficial third-party service. InkScroller is not affiliated with MyAnimeList or Jikan.

The Flutter client **does not call** MangaDex or Jikan directly — every request goes through the InkScroller backend, which acts as a read-only proxy. InkScroller does not store or redistribute content in bulk.

For legal compliance and takedown process details, see [`docs/legal/api-compliance.md`](docs/legal/api-compliance.md).

---

## 📄 License

This repository is released as **source-available / proprietary**.

- Copyright © 2026 Mercedes Franchesca Gonzalez Cejas
- All rights reserved
- See [`LICENSE`](LICENSE) for terms
