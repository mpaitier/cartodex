import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/pokemon_card.dart';

/// Une tuile de la grille de cartes : nom, numéro, rareté, et un
/// badge de possession qui bascule au tap.
///
/// Composant purement visuel, sans connaissance du Bloc parent :
/// toute interaction remonte via [onToggleOwned].
class CardGridItem extends StatelessWidget {
  const CardGridItem({
    required this.card,
    required this.owned,
    required this.onToggleOwned,
    super.key,
  });

  final PokemonCard card;
  final bool owned;
  final VoidCallback onToggleOwned;

  /// Numéro affiché sur 3 chiffres (ex: "#007"), quelle que soit la
  /// largeur du numéro brut renvoyé par la source.
  String get _formattedNumber => '#${card.localId.padLeft(3, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggleOwned,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: _CardArtPlaceholder(owned: owned)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        card.rarity == null
                            ? _formattedNumber
                            : '$_formattedNumber · ${card.rarity}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: _OwnershipBadge(owned: owned),
            ),
          ],
        ),
      ),
    );
  }
}

/// Remplace l'illustration de la carte tant qu'aucune source
/// d'images n'est branchée (voir README) : grisée quand la carte
/// n'est pas possédée, pour distinguer les deux états au premier
/// coup d'œil même sans visuel.
class _CardArtPlaceholder extends StatelessWidget {
  const _CardArtPlaceholder({required this.owned});

  final bool owned;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: owned ? Colors.black12 : Colors.black.withValues(alpha: 0.04),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: owned ? null : Theme.of(context).disabledColor,
        ),
      ),
    );
  }
}

/// Badge de possession affiché sur chaque tuile.
///
/// Violet profond au tap : couleur du compte principal. Le tap
/// simple ne distingue pas encore les comptes secondaires — ça
/// arrive avec la gestion de comptes (voir README), qui ajoutera
/// une variante bleue pour le double-tap.
class _OwnershipBadge extends StatelessWidget {
  const _OwnershipBadge({required this.owned});

  final bool owned;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundColor:
          owned ? AppColors.ownedByPrimaryAccount : Colors.black45,
      child: Icon(
        owned ? Icons.check : Icons.add,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}