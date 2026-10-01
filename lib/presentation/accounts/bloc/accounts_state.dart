import 'package:equatable/equatable.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';

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
    this.extrasByAccountId = const {},
    this.errorMessage,
  });

  final AccountsStatus status;
  final List<Account> accounts;

  /// Cartes en plus du compte principal, par compte secondaire
  /// (indexé par identifiant de compte). Vide tant qu'il n'y a pas de
  /// secondaire, ou si le calcul a échoué : la liste s'affiche alors
  /// sans compteurs plutôt que de tomber en erreur.
  final Map<String, AccountExtras> extrasByAccountId;

  final String? errorMessage;

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  AccountsState copyWith({
    AccountsStatus? status,
    List<Account>? accounts,
    Map<String, AccountExtras>? extrasByAccountId,
    String? errorMessage,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      extrasByAccountId: extrasByAccountId ?? this.extrasByAccountId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, accounts, extrasByAccountId, errorMessage];
}