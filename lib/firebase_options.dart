import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'flavors/flavor_config.dart';

class FirebaseOptionsSelector {
  static FirebaseOptions get current {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured');
    }
    //show a log of witch flavor is being used in terminal
    if (kDebugMode) {
      debugPrint('Flavor: ${FlavorConfig.instance.flavor}');
    }    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android();
      case TargetPlatform.iOS:
        return _ios();
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  // ---------- ANDROID ----------
  static FirebaseOptions _android() {
    switch (FlavorConfig.instance.flavor) {
      case Flavor.dev:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_ANDROID_DEV_API_KEY', defaultValue: 'REPLACE_ME'),
          appId: String.fromEnvironment('FIREBASE_ANDROID_DEV_APP_ID', defaultValue: 'REPLACE_ME'),
          messagingSenderId: String.fromEnvironment('FIREBASE_ANDROID_DEV_MESSAGING_SENDER_ID', defaultValue: 'REPLACE_ME'),
          projectId: String.fromEnvironment('FIREBASE_ANDROID_DEV_PROJECT_ID', defaultValue: 'REPLACE_ME'),
          storageBucket: String.fromEnvironment('FIREBASE_ANDROID_DEV_STORAGE_BUCKET', defaultValue: 'REPLACE_ME'),
        );

      case Flavor.staging:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_ANDROID_STAGING_API_KEY', defaultValue: 'REPLACE_ME'),
          appId: String.fromEnvironment('FIREBASE_ANDROID_STAGING_APP_ID', defaultValue: 'REPLACE_ME'),
          messagingSenderId: String.fromEnvironment('FIREBASE_ANDROID_STAGING_MESSAGING_SENDER_ID', defaultValue: 'REPLACE_ME'),
          projectId: String.fromEnvironment('FIREBASE_ANDROID_STAGING_PROJECT_ID', defaultValue: 'REPLACE_ME'),
          storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STAGING_STORAGE_BUCKET', defaultValue: 'REPLACE_ME'),
        );

      case Flavor.pro:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_ANDROID_PRO_API_KEY', defaultValue: 'REPLACE_ME'),
          appId: String.fromEnvironment('FIREBASE_ANDROID_PRO_APP_ID', defaultValue: 'REPLACE_ME'),
          messagingSenderId: String.fromEnvironment('FIREBASE_ANDROID_PRO_MESSAGING_SENDER_ID', defaultValue: 'REPLACE_ME'),
          projectId: String.fromEnvironment('FIREBASE_ANDROID_PRO_PROJECT_ID', defaultValue: 'REPLACE_ME'),
          storageBucket: String.fromEnvironment('FIREBASE_ANDROID_PRO_STORAGE_BUCKET', defaultValue: 'REPLACE_ME'),
        );
    }
  }

  // ---------- iOS ----------
  static FirebaseOptions _ios() {
    switch (FlavorConfig.instance.flavor) {
      case Flavor.dev:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_IOS_DEV_API_KEY', defaultValue: 'REPLACE_ME'),
          appId: String.fromEnvironment('FIREBASE_IOS_DEV_APP_ID', defaultValue: 'REPLACE_ME'),
          messagingSenderId: String.fromEnvironment('FIREBASE_IOS_DEV_MESSAGING_SENDER_ID', defaultValue: 'REPLACE_ME'),
          projectId: String.fromEnvironment('FIREBASE_IOS_DEV_PROJECT_ID', defaultValue: 'REPLACE_ME'),
          storageBucket: String.fromEnvironment('FIREBASE_IOS_DEV_STORAGE_BUCKET', defaultValue: 'REPLACE_ME'),
          iosBundleId: String.fromEnvironment('FIREBASE_IOS_DEV_BUNDLE_ID', defaultValue: 'com.example.inkscroller'),
        );

      case Flavor.staging:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_IOS_STAGING_API_KEY', defaultValue: 'REPLACE_ME'),
          appId: String.fromEnvironment('FIREBASE_IOS_STAGING_APP_ID', defaultValue: 'REPLACE_ME'),
          messagingSenderId: String.fromEnvironment('FIREBASE_IOS_STAGING_MESSAGING_SENDER_ID', defaultValue: 'REPLACE_ME'),
          projectId: String.fromEnvironment('FIREBASE_IOS_STAGING_PROJECT_ID', defaultValue: 'REPLACE_ME'),
          storageBucket: String.fromEnvironment('FIREBASE_IOS_STAGING_STORAGE_BUCKET', defaultValue: 'REPLACE_ME'),
          iosBundleId: String.fromEnvironment('FIREBASE_IOS_STAGING_BUNDLE_ID', defaultValue: 'com.example.inkscroller'),
        );

      case Flavor.pro:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_IOS_PRO_API_KEY', defaultValue: 'REPLACE_ME'),
          appId: String.fromEnvironment('FIREBASE_IOS_PRO_APP_ID', defaultValue: 'REPLACE_ME'),
          messagingSenderId: String.fromEnvironment('FIREBASE_IOS_PRO_MESSAGING_SENDER_ID', defaultValue: 'REPLACE_ME'),
          projectId: String.fromEnvironment('FIREBASE_IOS_PRO_PROJECT_ID', defaultValue: 'REPLACE_ME'),
          storageBucket: String.fromEnvironment('FIREBASE_IOS_PRO_STORAGE_BUCKET', defaultValue: 'REPLACE_ME'),
          iosBundleId: String.fromEnvironment('FIREBASE_IOS_PRO_BUNDLE_ID', defaultValue: 'com.example.inkscroller'),
        );
    }
  }
}
