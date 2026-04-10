# CI / CD – Firebase App Distribution

This repository uses **GitHub Actions** for two different pipelines:

1. **CI** on `push` / `pull_request` to `develop` → runs `fvm flutter analyze` and `fvm flutter test`
2. **CD / Firebase App Distribution** on published GitHub Releases → builds and distributes APKs

The pipeline builds and distributes **three flavors**:
- **DEV**
- **STAGING**
- **PRODUCTION (PRO)**

It also generates **automatic release notes**, attaches APKs to the GitHub Release, and enforces basic quality checks.

---

## 🚀 When do the workflows run?

### CI (`.github/workflows/ci.yml`)

- On every `push` to `develop`
- On every `pull_request` targeting `develop`

### CD / Release (`.github/workflows/firebase-distribution.yml`)

The release workflow is triggered **only** when a GitHub Release is published:

```text
GitHub → Releases → Draft new release → Publish
```

It does **not** build APKs on regular pushes or pull requests.

---

## 🔐 Required GitHub Secrets

The workflow depends on the following **repository secrets**:

Go to:
```
Settings → Secrets and variables → Actions
```

### 🔑 Authentication

The release workflow authenticates Firebase App Distribution with service account JSON per flavor.

| Secret name | Description |
|------------|-------------|
| `FIREBASE_SERVICE_ACCOUNT_JSON_DEV` | Service account JSON for the DEV Firebase project |
| `FIREBASE_SERVICE_ACCOUNT_JSON_STAGING` | Service account JSON for the STAGING Firebase project |
| `FIREBASE_SERVICE_ACCOUNT_JSON_PRO` | Service account JSON for the PRO Firebase project |

---

### 📱 Firebase App IDs

Each flavor is connected to a different Firebase project.

| Secret name | Description |
|------------|-------------|
| `FIREBASE_APP_ID_DEV` | Firebase App ID for **DEV** flavor |
| `FIREBASE_APP_ID_STAGING` | Firebase App ID for **STAGING** flavor |
| `FIREBASE_APP_ID_PRO` | Firebase App ID for **PRODUCTION** flavor |

### 🌐 API Base URLs

Because the app now reads the backend URL from `--dart-define=API_BASE_URL=...`, the release workflow also needs these secrets:

| Secret name | Description |
|------------|-------------|
| `API_BASE_URL_DEV` | Backend base URL for DEV builds |
| `API_BASE_URL_STAGING` | Backend base URL for STAGING builds |
| `API_BASE_URL_PRO` | Backend base URL for PRODUCTION builds |

---

### 📧 Testers

| Secret name | Description |
|------------|-------------|
| `FIREBASE_TESTERS` | Comma-separated list of tester emails **without spaces** |

Example:
```text
user1@gmail.com,user2@gmail.com
```

---

## 🧪 Quality checks performed

Before distributing any build, the release workflow runs:

1. `fvm flutter analyze`
2. `fvm flutter test`
3. Version validation (`pubspec.yaml` vs Git tag)

If any of these steps fail, **no APKs are distributed**.

The CI workflow runs the same quality gate earlier on every push/PR to `develop`.

---

## 🔢 Versioning rules

The workflow enforces version consistency.

### Example

```yaml
# pubspec.yaml
version: 0.1.0+2
```

```text
# Git tag
v0.1.0
```

Rules:
- The **semantic version** (`0.1.0`) must match the Git tag
- The build number (`+2`) is ignored for validation

---

## 📝 Release notes generation

Release notes are generated automatically from Git commit messages since the **previous tag**.

### Commit convention

Only the following commit prefixes are used for release notes:

| Prefix | Included in notes |
|------|------------------|
| `feat:` | ✅ New features |
| `fix:` | ✅ Bug fixes |
| `chore:` | ❌ Excluded |
| `ci:` | ❌ Excluded |

---

### Release notes per flavor

| Flavor | Included commits |
|------|-----------------|
| DEV | `feat:` + `fix:` |
| STAGING | `fix:` only |
| PRODUCTION | `fix:` only |

> Production release notes intentionally mirror staging release notes.

If no matching commits are found, a default message is used:

```text
- No user-visible changes
```

---

## 📦 Build & distribution

For each release, the workflow:

1. Builds APKs for all flavors
2. Uploads APKs as **assets** to the GitHub Release
3. Distributes APKs via **Firebase App Distribution**

Generated artifacts:

- `app-dev-release.apk`
- `app-staging-release.apk`
- `app-pro-release.apk`

---

## 🛠️ Local development commands

Run flavors locally:

```bash
fvm flutter run --flavor dev -t lib/main_dev.dart
fvm flutter run --flavor staging -t lib/main_staging.dart
fvm flutter run --flavor pro -t lib/main_pro.dart
```

---

## 🧠 Design decisions

- Firebase authentication uses per-flavor service account JSON secrets
- Flutter version is pinned in CI for reproducibility
- FVM is used in workflows for consistency with local development
- Release notes rely on commit conventions instead of manual input
- Production builds are only generated via GitHub Releases
- Release builds must pass `API_BASE_URL` explicitly so artifacts never fall back to the local LAN default

---

## ✅ Checklist before creating a release

- [ ] `pubspec.yaml` version updated
- [ ] Commits use `feat:` or `fix:` where appropriate
- [ ] All GitHub secrets are configured
- [ ] `API_BASE_URL_DEV`, `API_BASE_URL_STAGING`, and `API_BASE_URL_PRO` are configured
- [ ] Changes merged into `develop`

---

## 📌 Summary

This CI/CD setup ensures:
- Safe releases
- Consistent versioning
- Automatic changelogs
- Controlled Firebase distribution

No manual APK uploads are required.
