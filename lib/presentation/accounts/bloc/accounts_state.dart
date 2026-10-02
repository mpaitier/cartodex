import 'package:equatable/equatable.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';
import 'accounts_sort_option.dart';

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
    this.sortOption = AccountsSortOption.creationOrder,
    this.errorMessage,
  });

  final AccountsStatus status;

  /// Comptes dans leur ordre de création, tels que renvoyés par le
  /// use case. Pour l'affichage, voir [sortedAccounts].
  final List<Account> accounts;

  /// Cartes en plus du compte principal, par compte secondaire
  /// (indexé par identifiant de compte). Vide tant qu'il n'y a pas de
  /// secondaire, ou si le calcul a échoué : la liste s'affiche alors
  /// sans compteurs plutôt que de tomber en erreur.
  final Map<String, AccountExtras> extrasByAccountId;

  /// Critère de tri courant de la liste. Purement local à
  /// l'affichage : non persisté, retombe sur l'ordre de création à la
  /// réouverture de l'écran.
  final AccountsSortOption sortOption;

  final String? errorMessage;

  /// [accounts] ordonnés selon [sortOption], le compte principal
  /// toujours en premier. Seuls les secondaires sont triés ; à égalité
  /// (même nom, même total), l'ordre de création départage, pour un
  /// résultat déterministe.
  List<Account> get sortedAccounts {
    final primary = accounts.where((account) => account.isPrimary).toList();
    final secondaries =
        accounts.where((account) => !account.isPrimary).toList();

    switch (sortOption) {
      case AccountsSortOption.creationOrder:
        break;
      case AccountsSortOption.alphabetical:
        secondaries.sort(_compareByName);
      case AccountsSortOption.extraCards:
        secondaries.sort((a, b) {
          final byExtras = _extraTotal(b).compareTo(_extraTotal(a));
          return byExtras != 0 ? byExtras : _compareByName(a, b);
        });
    }
    return [...primary, ...secondaries];
  }

  int _extraTotal(Account account) =>
      extrasByAccountId[account.id]?.totals.total ?? 0;

  static int _compareByName(Account a, Account b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return byName != 0 ? byName : a.createdAt.compareTo(b.createdAt);
  }

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  AccountsState copyWith({
    AccountsStatus? status,
    List<Account>? accounts,
    Map<String, AccountExtras>? extrasByAccountId,
    AccountsSortOption? sortOption,
    String? errorMessage,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      extrasByAccountId: extrasByAccountId ?? this.extrasByAccountId,
      sortOption: sortOption ?? this.sortOption,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, accounts, extrasByAccountId, sortOption, errorMessage];
}