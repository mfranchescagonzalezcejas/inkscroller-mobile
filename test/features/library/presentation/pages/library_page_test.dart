import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkscroller_flutter/l10n/app_localizations.dart';
import 'package:inkscroller_flutter/core/error/failures.dart';
import 'package:inkscroller_flutter/core/network/connectivity_status_provider.dart';
import 'package:inkscroller_flutter/features/auth/domain/entities/app_user.dart';
import 'package:inkscroller_flutter/features/auth/domain/usecases/get_auth_state.dart';
import 'package:inkscroller_flutter/features/auth/domain/usecases/sign_in.dart';
import 'package:inkscroller_flutter/features/auth/domain/usecases/sign_out.dart';
import 'package:inkscroller_flutter/features/auth/domain/usecases/sign_up.dart';
import 'package:inkscroller_flutter/features/auth/presentation/providers/auth_notifier.dart';
import 'package:inkscroller_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:inkscroller_flutter/features/library/domain/entities/manga.dart';
import 'package:inkscroller_flutter/features/library/domain/usecases/get_manga_list.dart';
import 'package:inkscroller_flutter/features/library/domain/usecases/search_manga.dart';
import 'package:inkscroller_flutter/features/library/presentation/pages/library_page.dart';
import 'package:inkscroller_flutter/features/library/presentation/widgets/library_shimmer.dart';
import 'package:inkscroller_flutter/features/library/presentation/providers/library/library_provider.dart';
import 'package:inkscroller_flutter/features/library/presentation/providers/library/library_notifier.dart';
import 'package:inkscroller_flutter/flavors/flavor_config.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetMangaList extends Mock implements GetMangaList {}

class _MockSearchManga extends Mock implements SearchManga {}

class _MockSignIn extends Mock implements SignIn {}

class _MockSignUp extends Mock implements SignUp {}

class _MockSignOut extends Mock implements SignOut {}

class _MockGetAuthState extends Mock implements GetAuthState {}

AuthNotifier _makeStubAuthNotifier() {
  final getAuthState = _MockGetAuthState();
  when(() => getAuthState()).thenAnswer((_) => const Stream<AppUser?>.empty());

  return AuthNotifier(
    signIn: _MockSignIn(),
    signUp: _MockSignUp(),
    signOut: _MockSignOut(),
    getAuthState: getAuthState,
  );
}

void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    apiBaseUrl: 'http://localhost:8000',
    name: 'InkScroller Test',
  );

  late GetMangaList getMangaList;
  late SearchManga searchManga;

  Future<void> pumpLibraryPage(
    WidgetTester tester, {
    required GetMangaList getMangaList,
    required SearchManga searchManga,
    bool isOnline = true,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          connectivityStatusProvider.overrideWith(
            (ref) => Stream<bool>.value(isOnline),
          ),
          authProvider.overrideWith((_) => _makeStubAuthNotifier()),
          libraryProvider.overrideWith(
            (ref) => LibraryNotifier(getMangaList, searchManga),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryPage(),
        ),
      ),
    );
  }

  setUp(() {
    getMangaList = _MockGetMangaList();
    searchManga = _MockSearchManga();
  });

  testWidgets('shows shimmer while initial load is pending', (tester) async {
    final completer = Completer<Either<Failure, List<Manga>>>();

    when(
      () => getMangaList(limit: 20, offset: 0),
    ).thenAnswer((_) => completer.future);
    when(
      () => searchManga(any()),
    ).thenAnswer((_) async => const Right<Failure, List<Manga>>(<Manga>[]));

    await pumpLibraryPage(
      tester,
      getMangaList: getMangaList,
      searchManga: searchManga,
    );

    expect(find.byType(LibraryPage), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(LibraryShimmer), findsOneWidget);
  });

  testWidgets('shows empty catalogue message when no mangas are returned', (
    tester,
  ) async {
    when(
      () => getMangaList(limit: 20, offset: 0),
    ).thenAnswer((_) async => const Right<Failure, List<Manga>>(<Manga>[]));
    when(
      () => searchManga(any()),
    ).thenAnswer((_) async => const Right<Failure, List<Manga>>(<Manga>[]));

    await pumpLibraryPage(
      tester,
      getMangaList: getMangaList,
      searchManga: searchManga,
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay mangas disponibles'), findsOneWidget);
  });

  testWidgets('renders manga tiles when mangas are loaded', (tester) async {
    when(() => getMangaList(limit: 20, offset: 0)).thenAnswer(
      (_) async => Right<Failure, List<Manga>>(<Manga>[
        Manga(id: '1', title: 'Berserk'),
        Manga(id: '2', title: 'Monster'),
      ]),
    );
    when(
      () => searchManga(any()),
    ).thenAnswer((_) async => const Right<Failure, List<Manga>>(<Manga>[]));

    await pumpLibraryPage(
      tester,
      getMangaList: getMangaList,
      searchManga: searchManga,
    );
    await tester.pumpAndSettle();

    expect(find.text('Berserk'), findsOneWidget);
    expect(find.text('Monster'), findsOneWidget);
  });

  testWidgets(
    'shows search empty state when debounced search returns no results',
    (tester) async {
      when(() => getMangaList(limit: 20, offset: 0)).thenAnswer(
        (_) async => Right<Failure, List<Manga>>(<Manga>[
          Manga(id: '1', title: 'Initial'),
        ]),
      );
      when(
        () => searchManga('pluto'),
      ).thenAnswer((_) async => const Right<Failure, List<Manga>>(<Manga>[]));

      await pumpLibraryPage(
        tester,
        getMangaList: getMangaList,
        searchManga: searchManga,
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'pluto');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Sin resultados para "pluto"'), findsOneWidget);
    },
  );

  testWidgets(
    'shows offline banner when connectivity provider reports offline',
    (tester) async {
      when(
        () => getMangaList(limit: 20, offset: 0),
      ).thenAnswer((_) async => const Right<Failure, List<Manga>>(<Manga>[]));
      when(
        () => searchManga(any()),
      ).thenAnswer((_) async => const Right<Failure, List<Manga>>(<Manga>[]));

      await pumpLibraryPage(
        tester,
        getMangaList: getMangaList,
        searchManga: searchManga,
        isOnline: false,
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Sin conexión. Mostrando datos guardados si están disponibles.',
        ),
        findsOneWidget,
      );
    },
  );
}
