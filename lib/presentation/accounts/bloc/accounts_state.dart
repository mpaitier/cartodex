import 'package:equatable/equatable.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';
import '../../../domain/entities/accounts_sort_option.dart';
import '../../../domain/entities/card_set.dart';

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

/// Sentinelle de [AccountsState.copyWith] : distingue "ne pas toucher
/// à [AccountsState.setFilterId]" de "le remettre à `null`" (aucun
/// filtre), qu'un paramètre nommé nullable ne sait pas porter seul.
const _unset = Object();

/// État affiché par l'écran de gestion des comptes.
class AccountsState extends Equatable {
  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.extrasByAccountId = const {},
    this.sortOption = AccountsSortOption.creationOrder,
    this.setFilterId,
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

  /// Critère de tri courant de la liste. Relu au démarrage de l'écran
  /// depuis les préférences de l'appareil, et enregistré à chaque
  /// changement (voir `AccountsBloc`). Ordre de création tant que
  /// rien n'a été choisi.
  final AccountsSortOption sortOption;

  /// Extension choisie dans le filtre : seuls les comptes qui y ont des
  /// cartes en plus du principal sont affichés. `null` = aucun filtre.
  /// Purement local à l'écran, non mémorisé d'un lancement à l'autre.
  final String? setFilterId;

  final String? errorMessage;

  /// Extensions proposées dans le filtre : celles où au moins un compte
  /// secondaire a des cartes en plus (les autres ne montreraient aucun
  /// compte), triées par nom pour qu'on les retrouve facilement.
  List<CardSet> get availableFilterSets {
    final byId = <String, CardSet>{};
    for (final extras in extrasByAccountId.values) {
      for (final setExtras in extras.bySet) {
        byId[setExtras.set.id] = setExtras.set;
      }
    }
    return byId.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// L'extension du filtre, si elle fait encore partie des choix
  /// proposés. `null` sans filtre, ou si plus aucun compte n'y a de
  /// cartes en plus (ex: le principal vient de les obtenir) : le
  /// filtre ne s'applique alors plus, plutôt que de laisser une liste
  /// vide sans explication.
  CardSet? get activeFilterSet {
    final id = setFilterId;
    if (id == null) return null;
    for (final set in availableFilterSets) {
      if (set.id == id) return set;
    }
    return null;
  }

  /// Cartes en plus de [account] dans l'extension du filtre, ou `null`
  /// sans filtre actif (ou pour un compte qui n'y a rien).
  SetExtras? filteredSetExtrasFor(Account account) {
    final set = activeFilterSet;
    if (set == null) return null;
    final extras = extrasByAccountId[account.id];
    if (extras == null) return null;
    for (final setExtras in extras.bySet) {
      if (setExtras.set.id == set.id) return setExtras;
    }
    return null;
  }

  /// Comptes à afficher, ordonnés selon [sortOption].
  ///
  /// Sans filtre, le compte principal reste toujours en premier et
  /// seuls les secondaires sont triés. Avec un filtre d'extension
  /// ([activeFilterSet]), seuls les secondaires qui y ont des cartes en
  /// plus restent, sans le principal ; "Cartes en plus" trie alors sur
  /// les cartes de cette extension. À égalité (même nom, même total),
  /// l'ordre de création départage, pour un résultat déterministe.
  List<Account> get sortedAccounts {
    final filterSet = activeFilterSet;
    final primary = filterSet != null
        ? const <Account>[]
        : accounts.where((account) => account.isPrimary).toList();
    final secondaries = accounts
        .where((account) => !account.isPrimary)
        .where(
          (account) =>
              filterSet == null || filteredSetExtrasFor(account) != null,
        )
        .toList();

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

  int _extraTotal(Account account) {
    if (activeFilterSet != null) {
      return filteredSetExtrasFor(account)?.counts.total ?? 0;
    }
    return extrasByAccountId[account.id]?.totals.total ?? 0;
  }

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
    Object? setFilterId = _unset,
    String? errorMessage,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      extrasByAccountId: extrasByAccountId ?? this.extrasByAccountId,
      sortOption: sortOption ?? this.sortOption,
      setFilterId: identical(setFilterId, _unset)
          ? this.setFilterId
          : setFilterId as String?,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        accounts,
        extrasByAccountId,
        sortOption,
        setFilterId,
        errorMessage,
      ];
}