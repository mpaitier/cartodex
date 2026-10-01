import 'package:flutter/material.dart';

import '../../../domain/entities/pokemon_card.dart';
import 'card_grid_density.dart';
import 'card_grid_item.dart';

/// Grille des cartes d'un set (déjà filtrées par booster si besoin).
///
/// Extraite dans son propre composant pour garder l'écran centré
/// sur l'orchestration des états du Bloc plutôt que sur la mise en
/// page. [density] fixe le nombre de colonnes et le niveau de détail
/// des tuiles (voir [CardGridDensity]).
class CardGrid extends StatelessWidget {
  const CardGrid({
    required this.cards,
    required this.primaryOwnedCardIds,
    required this.secondaryOwnedCardIds,
    required this.onTap,
    required this.onDoubleTap,
    this.density = CardGridDensity.comfortable,
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
  final CardGridDensity density;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: density.columns,
        mainAxisSpacing: density.spacing,
        crossAxisSpacing: density.spacing,
        childAspectRatio: density.childAspectRatio,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CardGridItem(
          card: card,
          ownedByPrimary: primaryOwnedCardIds.contains(card.id),
          ownedBySecondary: secondaryOwnedCardIds.contains(card.id),
          compact: density.isCompact,
          onTap: () => onTap(card.id),
          onDoubleTap: () => onDoubleTap(card.id),
        );
      },
    );
  }
}