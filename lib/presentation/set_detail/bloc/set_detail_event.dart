import 'package:equatable/equatable.dart';

import '../../../core/constants/card_rarities.dart';
import 'ownership_filter.dart';

/// Événements gérés par [SetDetailBloc][set_detail_bloc.dart].
abstract class SetDetailEvent extends Equatable {
  const SetDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran : charge les cartes du set
/// [setId] et l'ensemble des identifiants de cartes possédées.
///
/// [ownerFilterAccountId], quand fourni, restreint l'affichage aux
/// seules cartes possédées par ce compte (utilisé depuis le détail
/// des cartes en plus d'un compte secondaire). `null` = aucune
/// restriction.
class SetDetailStarted extends SetDetailEvent {
  const SetDetailStarted(this.setId, {this.ownerFilterAccountId});

  final String setId;
  final String? ownerFilterAccountId;

  @override
  List<Object?> get props => [setId, ownerFilterAccountId];
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

/// Déclenché par le bouton "+" de l'écran (après confirmation) :
/// marque toutes les cartes de [cardIds] comme possédées par le
/// compte principal, en une seule fois. [cardIds] dépend du volet
/// actif de [CardGridPager][../widgets/card_grid_pager.dart] au
/// moment de l'appui — voir `SetDetailState.visibleCardsForGroup`.
class BulkCardsMarkedOwned extends SetDetailEvent {
  const BulkCardsMarkedOwned(this.cardIds);

  final List<String> cardIds;

  @override
  List<Object?> get props => [cardIds];
}

/// Déclenché par la sélection d'un booster dans le filtre.
/// `null` signifie "tous les boosters".
class PackFilterChanged extends SetDetailEvent {
  const PackFilterChanged(this.pack);

  final String? pack;

  @override
  List<Object?> get props => [pack];
}

/// Déclenché par un changement dans le filtre de rareté (multi-
/// sélection). Un ensemble vide signifie "toutes les raretés".
class RarityFilterChanged extends SetDetailEvent {
  const RarityFilterChanged(this.rarities);

  final Set<CardRarity> rarities;

  @override
  List<Object?> get props => [rarities];
}

/// Déclenché par la sélection d'une puce dans
/// [OwnershipFilterBar][../widgets/ownership_filter_bar.dart].
/// Remet à zéro le sous-filtre par compte secondaire.
class OwnershipFilterChanged extends SetDetailEvent {
  const OwnershipFilterChanged(this.filter);

  final OwnershipFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Déclenché par la sélection d'une puce dans
/// [SecondaryAccountFilterBar][../widgets/secondary_account_filter_bar.dart],
/// visible seulement quand le filtre "secondaires" est actif. `null`
/// signifie "tous les secondaires".
class SecondaryAccountFilterChanged extends SetDetailEvent {
  const SecondaryAccountFilterChanged(this.accountId);

  final String? accountId;

  @override
  List<Object?> get props => [accountId];
}