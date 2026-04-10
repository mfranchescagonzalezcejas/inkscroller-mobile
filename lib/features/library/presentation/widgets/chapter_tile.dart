import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/chapter.dart';

/// List tile widget for a single chapter entry in [MangaDetailPage].
///
/// Displays the chapter number (or "Extra"), title, and an icon indicating
/// whether the chapter is readable in-app or opens an external URL.
class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback? onTap;

  const ChapterTile({super.key, required this.chapter, this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = chapter.number == null
        ? context.l10n.extraLabel
        : context.l10n.chapterLabel(chapter.number.toString());

    Icon? trailing;

    if (chapter.external) {
      trailing = const Icon(Icons.open_in_new, size: 16);
    } else if (chapter.readable) {
      trailing = const Icon(Icons.menu_book, size: 16);
    }

    return ListTile(
      title: Text(label),
      subtitle: chapter.title != null ? Text(chapter.title!) : null,
      trailing: trailing,
      enabled: chapter.readable || chapter.external,
      onTap: onTap,
    );
  }
}
