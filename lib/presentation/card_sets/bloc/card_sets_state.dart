import 'package:equatable/equatable.dart';

import '../../../domain/entities/card_set.dart';

/// Étape du cycle de vie de [CardSetsState].
enum CardSetsStatus {
  /// Aucun chargement n'a encore été déclenché.
  initial,

  /// Lecture du référentiel local en cours.
  loading,

  /// Synchronisation avec TCGdex en cours. Les [CardSetsState.sets]
  /// affichés restent ceux du chargement précédent : l'écran ne se
  /// vide jamais pendant une synchronisation.
  syncing,

  /// Sets chargés (éventuellement une liste vide, si aucune
  /// synchronisation n'a jamais été faite).
  loaded,

  /// Échec de chargement ou de synchronisation.
  error,
}

/// État affiché par l'écran de liste des sets.
class CardSetsState extends Equatable {
  const CardSetsState({
    this.status = CardSetsStatus.initial,
    this.sets = const [],
    this.errorMessage,
  });

  final CardSetsStatus status;
  final List<CardSet> sets;
  final String? errorMessage;

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  CardSetsState copyWith({
    CardSetsStatus? status,
    List<CardSet>? sets,
    String? errorMessage,
  }) {
    return CardSetsState(
      status: status ?? this.status,
      sets: sets ?? this.sets,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sets, errorMessage];
}