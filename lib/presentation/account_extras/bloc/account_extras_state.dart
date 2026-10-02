import 'package:equatable/equatable.dart';

import '../../../domain/entities/account_extras.dart';

/// Étape du cycle de vie de [AccountExtrasState].
enum AccountExtrasStatus {
  /// Aucun chargement n'a encore été déclenché.
  initial,

  /// Calcul des cartes en plus en cours.
  loading,

  /// Calcul terminé (éventuellement sans aucun set).
  loaded,

  /// Échec du calcul.
  error,
}

/// État affiché par l'écran des cartes en plus d'un compte secondaire.
class AccountExtrasState extends Equatable {
  const AccountExtrasState({
    this.status = AccountExtrasStatus.initial,
    this.extras,
    this.errorMessage,
  });

  final AccountExtrasStatus status;
  final AccountExtras? extras;
  final String? errorMessage;

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  AccountExtrasState copyWith({
    AccountExtrasStatus? status,
    AccountExtras? extras,
    String? errorMessage,
  }) {
    return AccountExtrasState(
      status: status ?? this.status,
      extras: extras ?? this.extras,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, extras, errorMessage];
}