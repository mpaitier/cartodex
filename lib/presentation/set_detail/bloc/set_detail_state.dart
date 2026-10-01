import 'package:equatable/equatable.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/pokemon_card.dart';
import 'ownership_filter.dart';

/// Étape du cycle de vie de [SetDetailState].
enum SetDetailStatus {
  /// Aucun chargement n'a encore été déclenché.
  initial,

  /// Lecture des cartes du set et de la possession en cours.
  loading,

  /// Cartes chargées.
  loaded,

  /// Échec du chargement initial.
  error,
}

/// Sentinelle utilisée par [SetDetailState.copyWith] pour
/// distinguer "ne pas toucher à [SetDetailState.selectedPack]" (ou à
/// [SetDetailState.selectedSecondaryAccountId]) de "le remettre à
/// `null`" (qui est une valeur valide : "tous les boosters", "tous
/// les secondaires"). Un paramètre nommé nullable ne peut pas porter
/// cette distinction à lui seul.
const _unset = Object();

/// État affiché par l'écran de détail d'un set.
class SetDetailState extends Equatable {
  const SetDetailState({
    this.status = SetDetailStatus.initial,
    this.cards = const [],
    this.accounts = const [],
    this.ownershipByAccountId = const {},
    this.selectedPack,
    this.selectedRarities = const {},
    this.selectedOwnership = OwnershipFilter.all,
    this.selectedSecondaryAccountId,
    this.errorMessage,
  });

  final SetDetailStatus status;
  final List<PokemonCard> cards;

  /// Tous les comptes existants (principal et secondaires).
  final List<Account> accounts;

  /// Cartes possédées, par compte : `ownershipByAccountId[accountId]`
  /// donne les identifiants de cartes que ce compte possède (tous
  /// sets confondus — voir `GetOwnedCardIds`).
  final Map<String, Set<String>> ownershipByAccountId;

  /// Booster actuellement sélectionné dans le filtre. `null`
  /// signifie "tous les boosters".
  final String? selectedPack;

  /// Raretés cochées dans le filtre. Vide signifie "toutes les
  /// raretés" — contrairement à [selectedPack], pas besoin de
  /// sentinelle ici : un ensemble vide est déjà la valeur "aucun
  /// filtre", jamais une valeur "ne pas toucher".
  final Set<CardRarity> selectedRarities;

  /// Filtre de possession courant. [OwnershipFilter.all] signifie
  /// "aucun filtre" : comme pour [selectedRarities], la valeur
  /// "aucun filtre" est non nulle, pas besoin de sentinelle.
  final OwnershipFilter selectedOwnership;

  /// Compte secondaire précis choisi quand [selectedOwnership] vaut
  /// [OwnershipFilter.secondary]. `null` signifie "tous les comptes
  /// secondaires". Valeur brute : voir [activeSecondaryAccountId]
  /// pour celle réellement appliquée.
  final String? selectedSecondaryAccountId;

  final String? errorMessage;

  /// Le compte principal, s'il en existe un. `null` tant qu'aucun
  /// compte n'a été créé.
  Account? get primaryAccount {
    for (final account in accounts) {
      if (account.isPrimary) return account;
    }
    return null;
  }

  String? get primaryAccountId => primaryAccount?.id;

  List<Account> get secondaryAccounts =>
      accounts.where((account) => !account.isPrimary).toList();

  /// Les comptes secondaires qui possèdent au moins une carte de CE
  /// set — ceux qu'il a un sens de proposer dans
  /// `SecondaryAccountFilterBar`. [ownershipByAccountId] couvrant
  /// tous les sets, on recoupe avec [cards].
  List<Account> get secondaryAccountsWithCards {
    return secondaryAccounts.where((account) {
      final owned = ownershipByAccountId[account.id] ?? const <String>{};
      return cards.any((card) => owned.contains(card.id));
    }).toList();
  }

  /// Le compte secondaire réellement appliqué par le filtre : `null`
  /// (tous les secondaires) si le filtre de possession n'est pas
  /// [OwnershipFilter.secondary], ou si le compte choisi n'a plus de
  /// carte dans ce set (ex: il vient d'en perdre la dernière) —
  /// sinon la grille se viderait sans qu'aucune puce proposée ne
  /// l'explique.
  String? get activeSecondaryAccountId {
    final id = selectedSecondaryAccountId;
    if (id == null || selectedOwnership != OwnershipFilter.secondary) {
      return null;
    }
    final stillValid = secondaryAccountsWithCards.any((a) => a.id == id);
    return stillValid ? id : null;
  }

  /// Cartes possédées par le compte principal — ce que le tap
  /// simple bascule.
  Set<String> get primaryOwnedCardIds {
    final id = primaryAccountId;
    return id == null ? const {} : (ownershipByAccountId[id] ?? const {});
  }

  /// Union des cartes possédées par au moins un compte secondaire,
  /// pour le badge de la grille — le détail par compte se lit dans
  /// [ownershipByAccountId] au moment d'ouvrir le popup de
  /// double-tap.
  Set<String> get secondaryOwnedCardIds {
    final result = <String>{};
    for (final account in secondaryAccounts) {
      result.addAll(ownershipByAccountId[account.id] ?? const {});
    }
    return result;
  }

  /// Les choix à proposer dans `OwnershipFilterBar`. Vide tant
  /// qu'aucun compte principal n'existe (aucune possession à
  /// filtrer) ; sans compte secondaire, le choix "secondaires" est
  /// omis plutôt que de proposer une puce qui ne montrerait jamais
  /// rien.
  List<OwnershipFilter> get availableOwnershipFilters {
    if (primaryAccount == null) return const [];
    return [
      OwnershipFilter.all,
      OwnershipFilter.primary,
      if (secondaryAccounts.isNotEmpty) OwnershipFilter.secondary,
      OwnershipFilter.notOwned,
    ];
  }

  /// Raretés effectivement présentes dans ce set pour le volet
  /// [group] de [CardGridPager][../widgets/card_grid_pager.dart], dans
  /// l'ordre croissant de rareté, pour peupler `RarityFilterBar` —
  /// un sous-ensemble des 10 paliers possibles
  /// ([CardRarity.allTiers]). [CardGroupFilter.all] donne toutes les
  /// raretés du set, sans restriction ; [CardGroupFilter.diamond] et
  /// [CardGroupFilter.nonDiamond] restreignent respectivement aux
  /// cartes de la "collection de base" et aux cartes "alternatives"
  /// (voir [CardRarity.isBase]) — pour que le filtre affiché ne
  /// propose jamais une puce sans effet sur le volet actif.
  List<CardRarity> availableRaritiesForGroup(CardGroupFilter group) {
    final present = <CardRarity>{};
    for (final card in cards) {
      if (group == CardGroupFilter.diamond && !_isBase(card)) continue;
      if (group == CardGroupFilter.nonDiamond && !_isAlternative(card)) {
        continue;
      }
      final rarity = CardRarity.fromCode(card.rarity);
      if (rarity != null) present.add(rarity);
    }
    return CardRarity.allTiers.where(present.contains).toList();
  }

  /// Cartes à afficher compte tenu des filtres courants (booster,
  /// rareté et possession, cumulatifs).
  List<PokemonCard> get visibleCards {
    var result = cards;
    final pack = selectedPack;
    if (pack != null) {
      result = result.where((card) => card.packs.contains(pack)).toList();
    }
    if (selectedRarities.isNotEmpty) {
      result = result.where((card) {
        final rarity = CardRarity.fromCode(card.rarity);
        return rarity != null && selectedRarities.contains(rarity);
      }).toList();
    }
    if (selectedOwnership != OwnershipFilter.all) {
      // Calculés une seule fois : les getters reconstruisent leur
      // ensemble à chaque appel, trop coûteux dans une boucle.
      final primaryIds = primaryOwnedCardIds;
      final secondaryIds = _secondaryIdsForFilter;
      result = result
          .where((card) => _matchesOwnership(card, primaryIds, secondaryIds))
          .toList();
    }
    return result;
  }

  /// Les cartes secondaires que le filtre de possession doit
  /// considérer : celles du compte précis choisi
  /// ([activeSecondaryAccountId]), ou à défaut l'union de tous les
  /// secondaires. [activeSecondaryAccountId] n'est non nul que sur
  /// le filtre [OwnershipFilter.secondary] : "non possédées" reste
  /// donc toujours calculé sur l'union.
  Set<String> get _secondaryIdsForFilter {
    final accountId = activeSecondaryAccountId;
    if (accountId == null) return secondaryOwnedCardIds;
    return ownershipByAccountId[accountId] ?? const <String>{};
  }

  /// [visibleCards] restreintes au volet [group] de
  /// [CardGridPager][../widgets/card_grid_pager.dart] — le même
  /// partage losange / non-losange que [CardGridPager] applique en
  /// interne pour ses volets ([CardRarity.isBase]), mais exposé ici
  /// pour que le bouton "+" de [SetDetailPage][../view/set_detail_page.dart]
  /// sache exactement quelles cartes sont affichées à l'écran au
  /// moment de l'appui, volet par volet.
  List<PokemonCard> visibleCardsForGroup(CardGroupFilter group) {
    if (group == CardGroupFilter.diamond) {
      return visibleCards.where(_isBase).toList();
    }
    if (group == CardGroupFilter.nonDiamond) {
      return visibleCards.where(_isAlternative).toList();
    }
    return visibleCards;
  }

  /// Nombre de cartes de la "collection de base" (rareté losange)
  /// dans ce set, et combien le compte principal en possède — pour
  /// `SetProgressSummary`. Ignore les filtres de booster/rareté :
  /// c'est une mesure de progression sur tout le set, pas sur ce qui
  /// est actuellement affiché.
  int get baseTotal => cards.where(_isBase).length;

  int get baseOwned =>
      cards.where((c) => _isBase(c) && primaryOwnedCardIds.contains(c.id)).length;

  /// Symétrique de [baseTotal]/[baseOwned] pour les "cartes
  /// alternatives" (tout ce qui n'est pas losange : étoile, couronne,
  /// chromatique). Les cartes sans rareté connue (rares promos) ne
  /// comptent ni dans l'un ni dans l'autre.
  int get alternativeTotal => cards.where(_isAlternative).length;

  int get alternativeOwned => cards
      .where((c) => _isAlternative(c) && primaryOwnedCardIds.contains(c.id))
      .length;

  /// [baseOwned] plus les cartes losange possédées par au moins un
  /// compte secondaire mais pas par le principal — jamais les deux
  /// à la fois pour une même carte (pas de double-comptage), et
  /// jamais plus d'une fois même si plusieurs secondaires la
  /// possèdent. Ne dépasse donc jamais [baseTotal].
  int get baseOwnedAllAccounts {
    final secondaryOnly = secondaryOwnedCardIds.difference(primaryOwnedCardIds);
    final extra = cards.where((c) => _isBase(c) && secondaryOnly.contains(c.id));
    return baseOwned + extra.length;
  }

  /// Symétrique de [baseOwnedAllAccounts] pour les cartes
  /// alternatives.
  int get alternativeOwnedAllAccounts {
    final secondaryOnly = secondaryOwnedCardIds.difference(primaryOwnedCardIds);
    final extra =
        cards.where((c) => _isAlternative(c) && secondaryOnly.contains(c.id));
    return alternativeOwned + extra.length;
  }

  static bool _isBase(PokemonCard card) => CardRarity.isBase(card.rarity);

  /// Tout ce qui n'est pas losange, sans rareté connue y compris —
  /// exclure les cartes sans rareté ici les faisait disparaître à
  /// la fois de [baseTotal] et d'[alternativeTotal] (c'était le bug
  /// des totaux à 0 sur "Promo B").
  static bool _isAlternative(PokemonCard card) => !_isBase(card);

  /// Applique [selectedOwnership] à [card]. Le principal l'emporte
  /// sur les secondaires, comme pour le badge de `CardGridItem` : une
  /// carte possédée par les deux n'est que "principal".
  bool _matchesOwnership(
    PokemonCard card,
    Set<String> primaryIds,
    Set<String> secondaryIds,
  ) {
    final byPrimary = primaryIds.contains(card.id);
    final bySecondary = secondaryIds.contains(card.id);
    switch (selectedOwnership) {
      case OwnershipFilter.all:
        return true;
      case OwnershipFilter.primary:
        return byPrimary;
      case OwnershipFilter.secondary:
        return bySecondary && !byPrimary;
      case OwnershipFilter.notOwned:
        return !byPrimary && !bySecondary;
    }
  }

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  SetDetailState copyWith({
    SetDetailStatus? status,
    List<PokemonCard>? cards,
    List<Account>? accounts,
    Map<String, Set<String>>? ownershipByAccountId,
    Object? selectedPack = _unset,
    Set<CardRarity>? selectedRarities,
    OwnershipFilter? selectedOwnership,
    Object? selectedSecondaryAccountId = _unset,
    String? errorMessage,
  }) {
    return SetDetailState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      accounts: accounts ?? this.accounts,
      ownershipByAccountId: ownershipByAccountId ?? this.ownershipByAccountId,
      selectedPack: identical(selectedPack, _unset)
          ? this.selectedPack
          : selectedPack as String?,
      selectedRarities: selectedRarities ?? this.selectedRarities,
      selectedOwnership: selectedOwnership ?? this.selectedOwnership,
      selectedSecondaryAccountId: identical(selectedSecondaryAccountId, _unset)
          ? this.selectedSecondaryAccountId
          : selectedSecondaryAccountId as String?,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cards,
        accounts,
        ownershipByAccountId,
        selectedPack,
        selectedRarities,
        selectedOwnership,
        selectedSecondaryAccountId,
        errorMessage,
      ];
}