import 'package:equatable/equatable.dart';

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
    this.ownedCardIds = const {},
    this.selectedPack,
    this.errorMessage,
  });

  final SetDetailStatus status;
  final List<PokemonCard> cards;
  final Set<String> ownedCardIds;

  /// Booster actuellement sélectionné dans le filtre. `null`
  /// signifie "tous les boosters".
  final String? selectedPack;

  final String? errorMessage;

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
    Set<String>? ownedCardIds,
    Object? selectedPack = _unset,
    String? errorMessage,
  }) {
    return SetDetailState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      ownedCardIds: ownedCardIds ?? this.ownedCardIds,
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
        ownedCardIds,
        selectedPack,
        errorMessage,
      ];
}