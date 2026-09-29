import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/sign_in_with_email.dart';
import '../../../domain/usecases/sign_in_with_google.dart';
import '../../../domain/usecases/sign_out.dart';
import '../../../domain/usecases/sign_up_with_email.dart';
import '../../../domain/usecases/watch_auth_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// ViewModel du compte applicatif (Firebase).
///
/// À durée de vie globale, contrairement aux autres Blocs de
/// l'application (enregistrés en `registerFactory`, une instance par
/// écran) : celui-ci est enregistré en singleton dans le conteneur
/// d'injection et fourni une seule fois à la racine de l'app (voir
/// `CartodexApp`) — il n'y a qu'un seul état de connexion pour toute
/// l'app, pas un par écran.
///
/// Écoute en continu `watchAuthState` : toute connexion, création de
/// compte ou déconnexion se traduit par un événement
/// [AuthUserChanged] déclenché par ce flux, jamais par une
/// transition d'état directe dans les handlers ci-dessous — évite de
/// dupliquer la logique "connecté / déconnecté" à deux endroits.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required WatchAuthState watchAuthState,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
  })  : _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        super(const AuthState()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);

    _authSubscription =
        watchAuthState().listen((user) => add(AuthUserChanged(user)));
  }

  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  late final StreamSubscription<AppUser?> _authSubscription;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: event.user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: event.user,
        clearUser: event.user == null,
      ),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {}, // Le passage à "authenticated" vient de _onUserChanged.
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {},
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {},
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut(const NoParams());
    // Le passage à "unauthenticated" vient lui aussi de
    // _onUserChanged.
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}