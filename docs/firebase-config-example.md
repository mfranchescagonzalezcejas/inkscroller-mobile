# Firebase Config — Estructura de ejemplo

> Este documento muestra la **estructura** de los archivos de configuración de Firebase sin valores reales.
> Nunca commitear archivos con valores reales.

---

## google-services.json (Android)

Ubicación esperada por flavor:

```
android/app/src/dev/google-services.json
android/app/src/staging/google-services.json
android/app/src/pro/google-services.json
```

Estructura (sin valores reales):

```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "your-firebase-project-id",
    "storage_bucket": "your-firebase-project-id.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:YOUR_PROJECT_NUMBER:android:YOUR_APP_ID",
        "android_client_info": {
          "package_name": "com.yourcompany.inkscroller.dev"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaYOUR_FIREBASE_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

### Cómo obtenerlo

1. Firebase Console → seleccionar proyecto → ⚙️ Project settings
2. Tab **General** → sección **Your apps** → seleccionar la app Android
3. Descargar `google-services.json`
4. Moverlo a `android/app/src/<flavor>/google-services.json`

---

## GoogleService-Info.plist (iOS)

Ubicación esperada por flavor:

```
ios/Runner/GoogleService-Info-dev.plist
ios/Runner/GoogleService-Info-staging.plist
ios/Runner/GoogleService-Info-pro.plist
```

Estructura (sin valores reales):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>API_KEY</key>
  <string>AIzaYOUR_FIREBASE_API_KEY</string>
  <key>GCM_SENDER_ID</key>
  <string>YOUR_PROJECT_NUMBER</string>
  <key>PLIST_VERSION</key>
  <string>1</string>
  <key>BUNDLE_ID</key>
  <string>com.yourcompany.inkscroller.dev</string>
  <key>PROJECT_ID</key>
  <string>your-firebase-project-id</string>
  <key>STORAGE_BUCKET</key>
  <string>your-firebase-project-id.appspot.com</string>
  <key>IS_ADS_ENABLED</key>
  <false/>
  <key>IS_ANALYTICS_ENABLED</key>
  <false/>
  <key>IS_APPINVITE_ENABLED</key>
  <true/>
  <key>IS_GCM_ENABLED</key>
  <true/>
  <key>IS_SIGNIN_ENABLED</key>
  <true/>
  <key>GOOGLE_APP_ID</key>
  <string>1:YOUR_PROJECT_NUMBER:ios:YOUR_APP_ID</string>
</dict>
</plist>
```

### Cómo obtenerlo

1. Firebase Console → seleccionar proyecto → ⚙️ Project settings
2. Tab **General** → sección **Your apps** → seleccionar la app iOS
3. Descargar `GoogleService-Info.plist`
4. Renombrar a `GoogleService-Info-<flavor>.plist`
5. Moverlo a `ios/Runner/`

---

## Rutas excluidas por .gitignore

Las siguientes rutas están cubiertas en `.gitignore` para prevenir commits accidentales:

```
android/app/src/dev/google-services.json
android/app/src/staging/google-services.json
android/app/src/pro/google-services.json
android/app/google-services.json
ios/Runner/GoogleService-Info*.plist
android/*.jks
android/*.keystore
android/key.properties
```

---

_Ver [`SECURITY_PUBLIC_READINESS.md`](../SECURITY_PUBLIC_READINESS.md) para instrucciones de inyección vía CI._
