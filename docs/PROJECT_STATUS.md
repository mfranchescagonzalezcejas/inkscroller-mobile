# InkScroller Flutter — Project Status

> Current version: **v0.6.0** · Last updated: 2026-04-13

---

## Current State

| Field | Value |
|-------|-------|
| Version | `0.6.0+29` |
| Status | Active development |
| Tests | 169 passing |
| Platforms | Android (dev / staging / pro flavors) |
| Backend | [inkscroller-api](https://github.com/mfranchescagonzalezcejas/inkscroller-api) (Python / FastAPI / Cloud Run) |

---

## What's Implemented (v0.6.0)

### Core Features
- **Manga catalog** — paginated browsing, debounced search, cover precaching
- **User library** — save/remove titles, status tracking (added/reading/completed/paused), backend-synced
- **Reading progress** — per-chapter progress preloaded on startup, synced to backend
- **Adaptive reader** — vertical scroll and paged modes, per-title override, settings panel (brightness, direction, AMOLED, immersive)
- **Firebase Auth** — email/password sign-in/sign-up, JWT interceptor, route guard
- **Preferences** — local-first with timestamp-based conflict resolution; app locale (ES/EN) independent from reading language
- **Offline support** — connectivity detection on key screens, preferences accessible when profile fetch fails

### Architecture & Engineering
- Clean Architecture (Presentation → Domain ← Data) across all features
- Screaming Architecture outer structure (feature-per-domain)
- Riverpod `StateNotifierProvider` state management
- get_it DI wired at startup
- go_router with `StatefulShellRoute` for persistent bottom nav
- 3 flavors (dev/staging/pro) with distinct Firebase projects and Cloud Run endpoints
- GitHub Actions CI (analyze + 169 tests) and Release pipeline (APK build matrix + Firebase App Distribution)

---

## Roadmap / Known Gaps

| Item | Status |
|------|--------|
| iOS support | Not started — Android only |
| Offline reading (chapter download) | Planned |
| Push notifications | Planned |
| Play Store submission | Pending |
| Deep links | Planned |

---

## Related

- **Backend:** [inkscroller-api](https://github.com/mfranchescagonzalezcejas/inkscroller-api)
- **Architecture doc:** [`docs/ARCHITECTURE.md`](ARCHITECTURE.md)
- **API integration:** [`docs/API_INTEGRATION.md`](API_INTEGRATION.md)
