import 'package:equatable/equatable.dart';

/// Événements gérés par [SetDetailBloc][set_detail_bloc.dart].
abstract class SetDetailEvent extends Equatable {
  const SetDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran : charge les cartes du set
/// [setId] et l'ensemble des identifiants de cartes possédées.
class SetDetailStarted extends SetDetailEvent {
  const SetDetailStarted(this.setId);

  final String setId;

  @override
  List<Object?> get props => [setId];
}

/// Déclenché par un appui simple sur une carte : bascule sa
/// possession pour le compte principal.
class CardOwnershipToggled extends SetDetailEvent {
  const CardOwnershipToggled(this.cardId);

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}

/// Déclenché par la sélection d'un compte dans le popup ouvert au
/// double-tap : bascule la possession de la carte pour ce compte
/// secondaire précis.
class SecondaryOwnershipToggled extends SetDetailEvent {
  const SecondaryOwnershipToggled({
    required this.cardId,
    required this.accountId,
  });

  final String cardId;
  final String accountId;

  @override
  List<Object?> get props => [cardId, accountId];
}

/// Déclenché par la sélection d'un booster dans le filtre.
/// `null` signifie "tous les boosters".
class PackFilterChanged extends SetDetailEvent {
  const PackFilterChanged(this.pack);

  final String? pack;

  @override
  List<Object?> get props => [pack];
}