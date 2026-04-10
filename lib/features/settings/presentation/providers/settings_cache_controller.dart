import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';

/// Small controller for settings actions related to cached library data.
class SettingsCacheController {
  const SettingsCacheController({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  /// Clears all persisted library cache entries.
  ///
  /// Returns [Right(null)] on success or [Left(Failure)] on error.
  Future<Either<Failure, void>> clearLibraryCache() async {
    try {
      final keys = sharedPreferences.getKeys().where(
        (k) => k.startsWith('library.'),
      );

      for (final key in keys) {
        await sharedPreferences.remove(key);
      }

      return const Right(null);
    } on Exception catch (error) {
      return Left(CacheFailure(message: error.toString()));
    }
  }

  /// Returns total byte size of all `library.*` cache entries in SharedPreferences.
  int getCacheSize() {
    final keys = sharedPreferences.getKeys().where(
      (k) => k.startsWith('library.'),
    );
    int total = 0;
    for (final key in keys) {
      final value = sharedPreferences.getString(key);
      if (value != null) total += value.length;
    }
    return total;
  }
}

/// Provides cache maintenance actions for the settings screen.
final settingsCacheControllerProvider = Provider<SettingsCacheController>((
  ref,
) {
  return SettingsCacheController(sharedPreferences: sl<SharedPreferences>());
});

/// Formatted cache size string (e.g. "12.4 KB", "1.2 MB").
final cacheSizeProvider = Provider<String>((ref) {
  final controller = ref.watch(settingsCacheControllerProvider);
  final bytes = controller.getCacheSize();
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / 1048576).toStringAsFixed(1)} MB';
});
