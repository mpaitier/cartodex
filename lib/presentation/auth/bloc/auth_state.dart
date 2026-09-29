import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_user.dart';

/// Étape du cycle de vie de [AuthState].
enum AuthStatus {
  /// Pas encore su si un utilisateur est connecté (le flux
  /// `authStateChanges` n'a pas encore émis sa première valeur).
  unknown,

  /// Une tentative de connexion/création/déconnexion est en cours.
  loading,

  authenticated,
  unauthenticated,

  /// Échec d'une tentative de connexion/création — [AuthState.user]
  /// garde sa valeur précédente (`null` si l'échec survient avant
  /// toute connexion), seul [AuthState.errorMessage] change.
  error,
}

/// État du compte applicatif (Firebase), à durée de vie globale —
/// voir [AuthBloc][auth_bloc.dart].
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}