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
/// distinguer "ne pas toucher à ce champ" de "le remettre à
/// `null`" (une valeur valide pour [SetDetailState.selectedPack]
/// comme pour [SetDetailState.activeAccountId]). Un paramètre
/// nommé nullable ne peut pas porter cette distinction à lui seul.
const _unset = Object();

/// État affiché par l'écran de détail d'un set.
class SetDetailState extends Equatable {
  const SetDetailState({
    this.status = SetDetailStatus.initial,
    this.cards = const [],
    this.ownedCardIds = const {},
    this.selectedPack,
    this.activeAccountId,
    this.errorMessage,
  });

  final SetDetailStatus status;
  final List<PokemonCard> cards;

  /// Cartes possédées par [activeAccountId] au sein de ce set.
  final Set<String> ownedCardIds;

  /// Booster actuellement sélectionné dans le filtre. `null`
  /// signifie "tous les boosters".
  final String? selectedPack;

  /// Compte pour lequel [ownedCardIds] est valable, et sur lequel
  /// portera le prochain tap de possession. `null` tant qu'aucun
  /// compte n'existe encore (voir [SetDetailBloc._onStarted][../bloc/set_detail_bloc.dart]) :
  /// les cartes restent consultables, mais la possession est
  /// désactivée jusqu'à la création d'un premier compte.
  final String? activeAccountId;

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
    Object? activeAccountId = _unset,
    String? errorMessage,
  }) {
    return SetDetailState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      ownedCardIds: ownedCardIds ?? this.ownedCardIds,
      selectedPack: identical(selectedPack, _unset)
          ? this.selectedPack
          : selectedPack as String?,
      activeAccountId: identical(activeAccountId, _unset)
          ? this.activeAccountId
          : activeAccountId as String?,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cards,
        ownedCardIds,
        selectedPack,
        activeAccountId,
        errorMessage,
      ];
}