import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/manga_reading_progress.dart';
import '../../domain/repositories/reading_progress_repository.dart';

class ReadingProgressRepositoryImpl implements ReadingProgressRepository {
  ReadingProgressRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _prefix = 'library.reading_progress.';

  @override
  Future<Map<String, MangaReadingProgress>> getAll() async {
    final Map<String, MangaReadingProgress> progressByManga =
        <String, MangaReadingProgress>{};

    for (final key in _prefs.getKeys().where(
      (entry) => entry.startsWith(_prefix),
    )) {
      final String? raw = _prefs.getString(key);
      if (raw == null) {
        continue;
      }

      try {
        final Map<String, dynamic> json =
            jsonDecode(raw) as Map<String, dynamic>;
        final progress = MangaReadingProgress.fromJson(json);
        progressByManga[progress.mangaId] = progress;
      } on Object {
        await _prefs.remove(key);
      }
    }

    return progressByManga;
  }

  @override
  Future<void> save(MangaReadingProgress progress) {
    return _prefs.setString(
      '$_prefix${progress.mangaId}',
      jsonEncode(progress.toJson()),
    );
  }
}
