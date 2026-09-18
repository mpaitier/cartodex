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
    required this.ownedCardIds,
    required this.onToggleOwned,
    super.key,
  });

  final List<PokemonCard> cards;
  final Set<String> ownedCardIds;
  final ValueChanged<String> onToggleOwned;

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
          owned: ownedCardIds.contains(card.id),
          onToggleOwned: () => onToggleOwned(card.id),
        );
      },
    );
  }
}