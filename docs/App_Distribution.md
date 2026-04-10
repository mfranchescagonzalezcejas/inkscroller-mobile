# 📦 Firebase App Distribution – Flutter (APK + Flavors + FVM)

Este proyecto usa **Firebase App Distribution** para distribuir **APK release** de Flutter usando:

- FVM
- Flavors (dev / staging / pro)
- Firebase App Distribution
- PowerShell en Windows
- APK (no AppBundle)

---

## 📋 Requisitos previos

- Flutter (gestionado con FVM)
- FVM
- Node.js
- Firebase CLI
- Cuenta y proyecto en Firebase
- App Android creada en Firebase por flavor
- Keystore configurado (APK firmado)

Comprobación rápida:

```powershell
fvm --version
flutter --version
firebase --version
node -v
```

---

## 🗂️ Estructura del proyecto

```
inkscroller_flutter/
 ├─ android/
 ├─ ios/
 ├─ lib/
 │   ├─ main_dev.dart
 │   ├─ main_staging.dart
 │   └─ main_pro.dart
 ├─ pubspec.yaml
 └─ deploy_app_distribution.ps1
```

---

## 🔢 Versionado (OBLIGATORIO)

Antes de cada distribución, actualiza `pubspec.yaml`:

```yaml
version: 0.1.5+15
```

El build number (`+15`) **siempre debe incrementarse**.

---

## 📄 Script de distribución (PowerShell)

Archivo: `deploy_app_distribution.ps1`

```powershell
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("dev","staging","pro")]
  [string]$Flavor
)

$TesterEmail = "mercedesgon03@gmail.com"

switch ($Flavor) {
  "dev" {
    $Main = "lib/main_dev.dart"
    $ApkPath = "build/app/outputs/flutter-apk/app-dev-release.apk"
    $FirebaseAppId = "1:708894048002:android:44445c9b94d14a6a29cc1b"
    $Notes = "DEV build"
  }
  "staging" {
    $Main = "lib/main_staging.dart"
    $ApkPath = "build/app/outputs/flutter-apk/app-staging-release.apk"
    $FirebaseAppId = "1:391760656950:android:676a75f224f59798e5b697"
    $Notes = "STAGING build"
  }
  "pro" {
    $Main = "lib/main_pro.dart"
    $ApkPath = "build/app/outputs/flutter-apk/app-pro-release.apk"
    $FirebaseAppId = "1:806863502436:android:afa6aa67fc46d548a83371"
    $Notes = "PRO build"
  }
}

fvm flutter build apk `
  --flavor $Flavor `
  -t $Main

firebase appdistribution:distribute `
  $ApkPath `
  --app $FirebaseAppId `
  --testers $TesterEmail `
  --release-notes $Notes
```

---

## 🔓 Permitir scripts en Windows (una sola vez)

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## ▶️ Uso

Desde la raíz del proyecto:

```powershell
.\deploy_app_distribution.ps1 dev
.\deploy_app_distribution.ps1 staging
.\deploy_app_distribution.ps1 pro
```

---

## 📩 Resultado

- APK release compilado con FVM
- Subido a Firebase App Distribution
- Email de descarga enviado al tester configurado

---

## 🧨 Errores comunes

- Ejecutar el script fuera de la carpeta del proyecto
- No incrementar el build number
- No usar FVM
- Keystore no configurado

---

## ✅ Estado

Setup profesional, automatizado y listo para escalar.
