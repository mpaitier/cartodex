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

/// État affiché par l'écran de gestion des comptes.
class AccountsState extends Equatable {
  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.extrasByAccountId = const {},
    this.sortOption = AccountsSortOption.creationOrder,
    this.setFilterIds = const {},
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

  /// Extensions cochées dans le filtre (multi-sélection) : seuls les
  /// comptes qui ont des cartes en plus du principal dans au moins
  /// l'une d'elles sont affichés. Vide = aucun filtre. Purement local à
  /// l'écran, non mémorisé d'un lancement à l'autre.
  final Set<String> setFilterIds;

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

  /// Extensions du filtre qui font encore partie des choix proposés,
  /// dans l'ordre de [availableFilterSets]. Une extension où plus aucun
  /// compte n'a de cartes en plus (ex: le principal vient de les
  /// obtenir) est ignorée, plutôt que de laisser une liste vide sans
  /// explication.
  List<CardSet> get activeFilterSets => availableFilterSets
      .where((set) => setFilterIds.contains(set.id))
      .toList();

  /// Vrai quand au moins une extension du filtre s'applique.
  bool get isSetFiltered => activeFilterSets.isNotEmpty;

  /// Cartes en plus de [account] cumulées sur les extensions du filtre,
  /// ou `null` sans filtre actif ou pour un compte qui n'a rien dans
  /// aucune d'elles.
  ExtraCounts? filteredCountsFor(Account account) {
    final ids = {for (final set in activeFilterSets) set.id};
    if (ids.isEmpty) return null;
    final matching = (extrasByAccountId[account.id]?.bySet ?? const [])
        .where((setExtras) => ids.contains(setExtras.set.id));
    if (matching.isEmpty) return null;
    return matching.fold<ExtraCounts>(
      const ExtraCounts(),
      (sum, setExtras) => sum + setExtras.counts,
    );
  }

  /// Cartes en plus de [account] dans l'extension du filtre quand une
  /// seule est cochée, `null` sinon. Sert au cadre vert "complète le
  /// principal", qui n'a de sens que pour une extension précise : sur
  /// des compteurs cumulés, il ne dirait pas laquelle.
  SetExtras? singleFilteredSetExtrasFor(Account account) {
    final sets = activeFilterSets;
    if (sets.length != 1) return null;
    for (final setExtras
        in extrasByAccountId[account.id]?.bySet ?? const <SetExtras>[]) {
      if (setExtras.set.id == sets.single.id) return setExtras;
    }
    return null;
  }

  /// Extensions à montrer dans les cases d'aperçu de [account] (voir
  /// `TopExtraSetsPreview`) : toutes ses extensions avec des cartes en
  /// plus sans filtre, seulement celles du filtre sinon. L'ordre reste
  /// celui de `AccountExtras.bySet` (losanges puis étoiles en plus).
  List<SetExtras> previewSetsFor(Account account) {
    final bySet = extrasByAccountId[account.id]?.bySet ?? const <SetExtras>[];
    if (!isSetFiltered) return bySet;
    final ids = {for (final set in activeFilterSets) set.id};
    return bySet.where((setExtras) => ids.contains(setExtras.set.id)).toList();
  }

  /// Comptes à afficher, ordonnés selon [sortOption].
  ///
  /// Sans filtre, le compte principal reste toujours en premier et
  /// seuls les secondaires sont triés. Avec un filtre d'extensions
  /// ([activeFilterSets]), seuls les secondaires qui ont des cartes en
  /// plus dans au moins l'une d'elles restent, sans le principal ;
  /// "Cartes en plus" trie alors sur les cartes de ces extensions. À égalité (même nom, même total),
  /// l'ordre de création départage, pour un résultat déterministe.
  List<Account> get sortedAccounts {
    final filtered = isSetFiltered;
    final primary = filtered
        ? const <Account>[]
        : accounts.where((account) => account.isPrimary).toList();
    final secondaries = accounts
        .where((account) => !account.isPrimary)
        .where((account) => !filtered || filteredCountsFor(account) != null)
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
    if (isSetFiltered) return filteredCountsFor(account)?.total ?? 0;
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
    Set<String>? setFilterIds,
    String? errorMessage,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      extrasByAccountId: extrasByAccountId ?? this.extrasByAccountId,
      sortOption: sortOption ?? this.sortOption,
      setFilterIds: setFilterIds ?? this.setFilterIds,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        accounts,
        extrasByAccountId,
        sortOption,
        setFilterIds,
        errorMessage,
      ];
}