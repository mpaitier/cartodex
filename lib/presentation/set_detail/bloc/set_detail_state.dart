import 'package:equatable/equatable.dart';

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

  /// Cartes à afficher compte tenu du filtre courant.
  List<PokemonCard> get visibleCards {
    final pack = selectedPack;
    if (pack == null) return cards;
    return cards.where((card) => card.packs.contains(pack)).toList();
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
        errorMessage,
      ];
}