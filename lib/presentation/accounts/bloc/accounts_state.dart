import 'package:equatable/equatable.dart';

import '../../../domain/entities/account.dart';

/// Étape du cycle de vie de [AccountsState].
enum AccountsStatus {
  /// Aucun chargement n'a encore été déclenché.
  initial,

  /// Lecture des comptes en cours.
  loading,

  /// Comptes chargés (éventuellement une liste vide).
  loaded,

  /// Échec du chargement initial.
  error,
}

/// État affiché par l'écran de gestion des comptes.
class AccountsState extends Equatable {
  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.errorMessage,
  });

  final AccountsStatus status;
  final List<Account> accounts;
  final String? errorMessage;

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  AccountsState copyWith({
    AccountsStatus? status,
    List<Account>? accounts,
    String? errorMessage,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, accounts, errorMessage];
}