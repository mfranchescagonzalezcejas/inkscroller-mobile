class MangaReadingProgress {
  const MangaReadingProgress({
    required this.mangaId,
    this.readChapterIds = const <String>{},
    this.totalChaptersCount = 0,
  });

  final String mangaId;
  final Set<String> readChapterIds;
  final int totalChaptersCount;

  int get readChaptersCount => readChapterIds.length;

  bool get hasKnownTotal => totalChaptersCount > 0;

  bool isChapterRead(String chapterId) => readChapterIds.contains(chapterId);

  MangaReadingProgress copyWith({
    Set<String>? readChapterIds,
    int? totalChaptersCount,
  }) {
    return MangaReadingProgress(
      mangaId: mangaId,
      readChapterIds: readChapterIds ?? this.readChapterIds,
      totalChaptersCount: totalChaptersCount ?? this.totalChaptersCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mangaId': mangaId,
      'readChapterIds': readChapterIds.toList()..sort(),
      'totalChaptersCount': totalChaptersCount,
    };
  }

  factory MangaReadingProgress.fromJson(Map<String, dynamic> json) {
    return MangaReadingProgress(
      mangaId: json['mangaId'] as String,
      readChapterIds:
          ((json['readChapterIds'] as List<dynamic>?) ?? const <dynamic>[])
              .whereType<String>()
              .toSet(),
      totalChaptersCount: (json['totalChaptersCount'] as num?)?.toInt() ?? 0,
    );
  }
}
