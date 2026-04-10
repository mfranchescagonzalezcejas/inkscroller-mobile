import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inkscroller_flutter/core/constants/app_constants.dart';
import 'package:inkscroller_flutter/core/design/design_tokens.dart';
import 'package:inkscroller_flutter/core/l10n/l10n.dart';
import 'package:inkscroller_flutter/core/network/connectivity_status_provider.dart';
import 'package:inkscroller_flutter/core/widgets/app_top_bar.dart';
import 'package:inkscroller_flutter/core/widgets/catalog_tab_bar.dart';
import 'package:inkscroller_flutter/core/widgets/offline_banner.dart';
import 'package:inkscroller_flutter/features/library/presentation/widgets/manga_tile.dart';
import 'package:inkscroller_flutter/features/library/domain/entities/manga.dart';
import 'package:inkscroller_flutter/features/library/presentation/constants/library_ui_constants.dart';
import 'package:inkscroller_flutter/features/auth/presentation/providers/auth_provider.dart';

import '../../../../core/widgets/inkscroller_logo_loader.dart';
import '../providers/library/library_provider.dart';
import '../providers/library/library_state.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../widgets/library_shimmer.dart';

/// Full-catalogue browsing page with debounced search and infinite scroll.
///
/// Renders a responsive masonry grid of [MangaTile] widgets. Watches
/// [libraryProvider] for paginated state and triggers
/// [LibraryNotifier.loadMore] when the user scrolls near the bottom.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  bool _canTriggerLoadMore = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController = TextEditingController();
  }

  void _onScroll() {
    final state = ref.read(libraryProvider);

    // No paginamos mientras se está buscando
    if (state.isSearching || state.query.trim().isNotEmpty) return;

    if (!_scrollController.hasClients) return;

    final thresholdReached =
        _scrollController.position.extentAfter <=
        AppConstants.mangaListPrefetchExtent;

    if (thresholdReached && !state.isLoadingMore && _canTriggerLoadMore) {
      _canTriggerLoadMore = false;
      ref.read(libraryProvider.notifier).loadMore();
    }

    if (!thresholdReached) {
      _canTriggerLoadMore = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryProvider);
    final authState = ref.watch(authProvider);
    final bool isOffline = ref.watch(connectivityStatusProvider).maybeWhen(
      data: (isOnline) => !isOnline,
      orElse: () => false,
    );

    // Mantiene el TextField sincronizado si el estado cambia desde fuera
    if (_searchController.text != state.query) {
      _searchController.value = _searchController.value.copyWith(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.voidLowest,
      appBar: AppTopBar(authState: authState),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (isOffline) const OfflineBanner(),
          _LibraryHeader(mangaCount: state.mangas.length),
          _LibrarySearchBar(
            controller: _searchController,
            query: state.query,
            onChanged: (value) {
              ref.read(libraryProvider.notifier).setQuery(value);
            },
            onClear: () {
              _searchController.clear();
              ref.read(libraryProvider.notifier).clearSearch();
            },
          ),
          _LibraryTabs(
            selectedIndex: _selectedTabIndex,
            onSelected: (index) {
              setState(() => _selectedTabIndex = index);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(libraryProvider.notifier).refresh(),
              child: _LibraryBody(
                state: state,
                controller: _scrollController,
                selectedTabIndex: _selectedTabIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  final int mangaCount;

  const _LibraryHeader({required this.mangaCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.libraryTitle,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.libraryCollectionsCount(mangaCount),
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _LibrarySearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search, color: AppColors.outline, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.searchMangaHint,
                  hintStyle: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    color: AppColors.outline,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                onSubmitted: onChanged,
              ),
            ),
            if (query.trim().isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.clear, color: AppColors.outline, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _LibraryTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _LibraryTabs({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return CatalogTabBar(
      labels: <String>[
        context.l10n.libraryTabAll,
        context.l10n.libraryTabReading,
        context.l10n.libraryTabCompleted,
        context.l10n.libraryTabOnHold,
      ],
      selectedIndex: selectedIndex,
      onSelected: onSelected,
    );
  }
}

class _LibraryBody extends StatelessWidget {
  final LibraryState state;
  final ScrollController controller;
  final int selectedTabIndex;

  const _LibraryBody({
    required this.state,
    required this.controller,
    required this.selectedTabIndex,
  });

  List<Manga> _filterByTab(List<Manga> mangas) {
    if (selectedTabIndex == 0) return mangas;

    // NOTE:
    // Backend currently exposes generic publication status (e.g. ongoing,
    // completed, hiatus). Until per-user reading states are available,
    // these tabs use the closest semantic mapping to keep UI behavior functional.
    switch (selectedTabIndex) {
      case 1: // Reading
        return mangas
            .where(
              (manga) =>
                  (manga.status ?? '').toLowerCase() ==
                  LibraryUiConstants.ongoingStatus,
            )
            .toList();
      case 2: // Completed
        return mangas
            .where(
              (manga) =>
                  (manga.status ?? '').toLowerCase() ==
                  LibraryUiConstants.completedStatus,
            )
            .toList();
      case 3: // On Hold
        return mangas
            .where(
              (manga) =>
                  (manga.status ?? '').toLowerCase() ==
                  LibraryUiConstants.hiatusStatus,
            )
            .toList();
      default:
        return mangas;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.mangas.isEmpty) {
      return const LibraryShimmer();
    }

    if (state.isSearching && state.mangas.isEmpty) {
      return const Center(child: InkScrollerLogoLoader());
    }

    final filteredMangas = _filterByTab(state.mangas);

    if (filteredMangas.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Text(
                  state.query.trim().isEmpty
                      ? context.l10n.noMangasAvailable
                      : context.l10n.noSearchResults(state.query),
                ),
              ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        final int crossAxisCount;
        if (width >= LibraryUiConstants.largeGridBreakpoint) {
          crossAxisCount = LibraryUiConstants.largeGridColumns;
        } else if (width >= LibraryUiConstants.mediumGridBreakpoint) {
          crossAxisCount = LibraryUiConstants.mediumGridColumns;
        } else {
          crossAxisCount = LibraryUiConstants.smallGridColumns;
        }

        final showBottomLoader = state.isLoadingMore && !state.isSearching;
        final showEndReached =
            !state.isSearching && !state.isLoadingMore && !state.hasMore;
        final double bottomInset = MediaQuery.of(context).padding.bottom;
        final double bottomSafePadding =
            LibraryUiConstants.cardGridBottomPadding + bottomInset;

        return MasonryGridView.builder(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            LibraryUiConstants.horizontalPadding,
            0,
            LibraryUiConstants.horizontalPadding,
            bottomSafePadding,
          ),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          mainAxisSpacing: LibraryUiConstants.gridMainSpacing,
          crossAxisSpacing: LibraryUiConstants.gridCrossSpacing,
          itemCount:
              filteredMangas.length +
              (showBottomLoader ? 1 : 0) +
              (showEndReached ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= filteredMangas.length) {
              if (showBottomLoader && index == filteredMangas.length) {
                return const Center(child: InkScrollerLogoLoader());
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(context.l10n.noMoreMangaToLoad),
                ),
              );
            }

            final manga = filteredMangas[index];
            return MangaTile(manga: manga);
          },
        );
      },
    );
  }
}
