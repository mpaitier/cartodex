import 'package:flutter/material.dart';

import '../../../domain/entities/pokemon_card.dart';
import 'card_grid_item.dart';

/// Grille des cartes d'un set (déjà filtrées par booster si besoin).
///
/// Extraite dans son propre composant pour garder l'écran centré
/// sur l'orchestration des états du Bloc plutôt que sur la mise en
/// page.
class CardGrid extends StatelessWidget {
  const CardGrid({
    required this.cards,
    required this.primaryOwnedCardIds,
    required this.secondaryOwnedCardIds,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  final List<PokemonCard> cards;

  /// Cartes possédées par le compte principal (tap simple).
  final Set<String> primaryOwnedCardIds;

  /// Cartes possédées par au moins un compte secondaire (peu
  /// importe lequel, ici — le détail se choisit dans le popup
  /// ouvert par [onDoubleTap]).
  final Set<String> secondaryOwnedCardIds;

  final ValueChanged<String> onTap;
  final ValueChanged<String> onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CardGridItem(
          card: card,
          ownedByPrimary: primaryOwnedCardIds.contains(card.id),
          ownedBySecondary: secondaryOwnedCardIds.contains(card.id),
          onTap: () => onTap(card.id),
          onDoubleTap: () => onDoubleTap(card.id),
        );
      },
    );
  }
}