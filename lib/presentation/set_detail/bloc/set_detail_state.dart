import 'package:equatable/equatable.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/pokemon_card.dart';

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
/// distinguer "ne pas toucher à [SetDetailState.selectedPack]" de
/// "le remettre à `null`" (qui est une valeur valide : "tous les
/// boosters"). Un paramètre nommé nullable ne peut pas porter cette
/// distinction à lui seul.
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
    this.errorMessage,
  });

  final SetDetailStatus status;
  final List<PokemonCard> cards;

  /// Tous les comptes existants (principal et secondaires).
  final List<Account> accounts;

  /// Cartes possédées, par compte : `ownershipByAccountId[accountId]`
  /// donne les identifiants de cartes de ce set que ce compte
  /// possède.
  final Map<String, Set<String>> ownershipByAccountId;

  /// Booster actuellement sélectionné dans le filtre. `null`
  /// signifie "tous les boosters".
  final String? selectedPack;

  /// Raretés cochées dans le filtre. Vide signifie "toutes les
  /// raretés" — contrairement à [selectedPack], pas besoin de
  /// sentinelle ici : un ensemble vide est déjà la valeur "aucun
  /// filtre", jamais une valeur "ne pas toucher".
  final Set<CardRarity> selectedRarities;

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

  /// Raretés effectivement présentes dans ce set, dans l'ordre
  /// croissant de rareté, pour peupler le filtre — un sous-ensemble
  /// des 10 paliers possibles ([CardRarity.allTiers]).
  List<CardRarity> get availableRarities {
    final present = <CardRarity>{};
    for (final card in cards) {
      final rarity = CardRarity.fromCode(card.rarity);
      if (rarity != null) present.add(rarity);
    }
    return CardRarity.allTiers.where(present.contains).toList();
  }

  /// Cartes à afficher compte tenu des filtres courants (booster et
  /// rareté, cumulatifs).
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
    return result;
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
        errorMessage,
      ];
}