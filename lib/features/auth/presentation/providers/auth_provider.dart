import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../domain/usecases/get_auth_state.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

final GetIt _sl = GetIt.instance;

/// Riverpod provider that exposes [AuthNotifier] to the widget tree.
///
/// Resolves use cases from get_it following the project convention that
/// providers bridge get_it singletons to the Riverpod layer.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signIn: _sl<SignIn>(),
    signUp: _sl<SignUp>(),
    signOut: _sl<SignOut>(),
    getAuthState: _sl<GetAuthState>(),
  );
});
