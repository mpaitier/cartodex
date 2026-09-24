import 'package:flutter/material.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/pokemon_card.dart';

/// Une tuile de la grille de cartes : nom, numéro, rareté, et un
/// badge de possession.
///
/// Composant purement visuel, sans connaissance du Bloc parent :
/// le tap simple (compte principal) remonte via [onTap], le
/// double-tap (choix d'un compte secondaire) via [onDoubleTap].
class CardGridItem extends StatelessWidget {
  const CardGridItem({
    required this.card,
    required this.ownedByPrimary,
    required this.ownedBySecondary,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  final PokemonCard card;
  final bool ownedByPrimary;
  final bool ownedBySecondary;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  /// Numéro sur 3 chiffres (ex: "007"), quelle que soit la largeur
  /// du numéro brut renvoyé par la source. Sans `#` : affiché en
  /// grand à la place de l'image tant qu'aucune source d'images
  /// n'est branchée (voir README), le `#` n'apporterait rien.
  String get _paddedNumber => card.localId.padLeft(3, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owned = ownedByPrimary || ownedBySecondary;
    final rarity = CardRarity.fromCode(card.rarity);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _CardArtPlaceholder(
                    owned: owned,
                    number: _paddedNumber,
                  ),
                ),
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
                      if (rarity != null)
                        Text(
                          rarity.symbol,
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
              child: _OwnershipBadge(
                ownedByPrimary: ownedByPrimary,
                ownedBySecondary: ownedBySecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Remplace l'illustration de la carte tant qu'aucune source
/// d'images n'est branchée (voir README) : le numéro de la carte y
/// est affiché en grand, plutôt qu'une icône générique identique
/// pour toutes les cartes. Grisée quand la carte n'est pas
/// possédée, pour distinguer les deux états au premier coup d'œil
/// même sans visuel.
class _CardArtPlaceholder extends StatelessWidget {
  const _CardArtPlaceholder({required this.owned, required this.number});

  final bool owned;
  final String number;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: owned ? Colors.black12 : Colors.black.withValues(alpha: 0.04),
      child: Center(
        child: Text(
          number,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: owned ? null : Theme.of(context).disabledColor,
              ),
        ),
      ),
    );
  }
}

/// Badge de possession affiché sur chaque tuile.
///
/// Le principal l'emporte visuellement si la carte est possédée à
/// la fois par le compte principal et par un compte secondaire :
/// violet profond (tap simple) prioritaire sur bleu (double-tap,
/// compte secondaire), lui-même prioritaire sur l'état neutre.
class _OwnershipBadge extends StatelessWidget {
  const _OwnershipBadge({
    required this.ownedByPrimary,
    required this.ownedBySecondary,
  });

  final bool ownedByPrimary;
  final bool ownedBySecondary;

  @override
  Widget build(BuildContext context) {
    if (ownedByPrimary) {
      return const CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.ownedByPrimaryAccount,
        child: Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    if (ownedBySecondary) {
      return const CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.ownedBySecondaryAccount,
        child: Icon(Icons.arrow_upward, size: 14, color: Colors.white),
      );
    }
    return const CircleAvatar(
      radius: 12,
      backgroundColor: Colors.black45,
      child: Icon(Icons.add, size: 14, color: Colors.white),
    );
  }
}