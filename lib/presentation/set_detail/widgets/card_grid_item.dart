import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/pokemon_card.dart';
import 'grayscale_filter.dart';

/// Une tuile de la grille de cartes : illustration centrée, nom,
/// numéro et rareté, et un badge de possession.
///
/// En mode [compact] (grille à 5 colonnes, voir `CardGridDensity`),
/// seuls l'illustration et le badge (réduit) restent : le texte ne
/// tiendrait pas dans une tuile aussi étroite.
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
    this.compact = false,
    super.key,
  });

  final PokemonCard card;
  final bool ownedByPrimary;
  final bool ownedBySecondary;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  /// Vrai pour la grille dense : texte masqué, badge réduit.
  final bool compact;

  /// Numéro sur 3 chiffres (ex: "007"), quelle que soit la largeur
  /// du numéro brut renvoyé par la source. Affiché à la fois dans
  /// le texte sous l'illustration, et en grand à la place de
  /// celle-ci quand elle ne charge pas (voir [_NumberFallback]).
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
                  child: _CardArt(
                    imageUrl: card.imageUrl,
                    owned: owned,
                    number: _paddedNumber,
                    compact: compact,
                  ),
                ),
                if (!compact)
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#$_paddedNumber',
                              style: theme.textTheme.labelSmall,
                            ),
                            if (rarity != null)
                              Text(
                                rarity.symbol,
                                style: theme.textTheme.labelSmall,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Positioned(
              top: compact ? 2 : 4,
              right: compact ? 2 : 4,
              child: _OwnershipBadge(
                ownedByPrimary: ownedByPrimary,
                ownedBySecondary: ownedBySecondary,
                compact: compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Illustration de la carte, centrée sans être recadrée
/// (`BoxFit.contain`, quelle que soit la proportion de l'image
/// renvoyée par pocketcards.net). [imageUrl] est reconstruit à
/// partir de la convention de nommage du site (voir
/// `CardModel.fromJson` et `PocketCardsImageSlug`), sans certitude
/// absolue sur son exactitude pour chaque carte : si le chargement
/// échoue, ou tant qu'aucune URL n'est disponible, retombe sur le
/// numéro de la carte affiché en grand plutôt qu'une icône
/// générique identique pour toutes les cartes.
///
/// Quand la carte n'est possédée par aucun compte (principal ou
/// secondaire), l'illustration passe en noir et blanc (voir
/// [GrayscaleFilter]) et le fond est légèrement assombri, pour
/// distinguer les deux états au premier coup d'œil.
///
/// Chaque URL tentée est loguée (voir [AppLogger]) : en INFO au
/// moment de la construction, en ERROR si `CachedNetworkImage`
/// échoue à la charger — le but est de pouvoir vérifier d'un coup
/// d'œil dans la console si le lien reconstruit est correct, sans
/// devoir copier-coller chaque URL à la main.
class _CardArt extends StatelessWidget {
  const _CardArt({
    required this.imageUrl,
    required this.owned,
    required this.number,
    required this.compact,
  });

  final String? imageUrl;
  final bool owned;
  final String number;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null) {
      return _NumberFallback(owned: owned, number: number);
    }
    AppLogger.log('INFO', 'Carte #$number : $url');
    return ColoredBox(
      color: owned ? Colors.black12 : Colors.black.withValues(alpha: 0.04),
      child: Padding(
        padding: EdgeInsets.all(compact ? 2 : 4),
        child: GrayscaleFilter(
          enabled: !owned,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            placeholder: (context, _) => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, failedUrl, error) {
              // L'URL et l'erreur exacte permettent de tester le lien
              // directement dans un navigateur (voir AppLogger, qui ne
              // s'exécute qu'en debug).
              AppLogger.log(
                'ERROR',
                'Carte #$number introuvable : $failedUrl ($error)',
              );
              return _NumberFallback(owned: owned, number: number);
            },
          ),
        ),
      ),
    );
  }
}

class _NumberFallback extends StatelessWidget {
  const _NumberFallback({required this.owned, required this.number});

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
/// violet profond (tap simple) prioritaire sur jaune (double-tap,
/// compte secondaire), lui-même prioritaire sur l'état neutre.
/// L'icône du badge secondaire est foncée : le blanc ne se lit pas
/// sur du jaune. En mode [compact], le badge est réduit pour ne pas
/// masquer l'illustration.
///
/// Le badge n'est jamais filtré en noir et blanc : il se trouve hors
/// de l'illustration, et ses couleurs portent l'information.
class _OwnershipBadge extends StatelessWidget {
  const _OwnershipBadge({
    required this.ownedByPrimary,
    required this.ownedBySecondary,
    required this.compact,
  });

  final bool ownedByPrimary;
  final bool ownedBySecondary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 9.0 : 12.0;
    final iconSize = compact ? 11.0 : 14.0;
    if (ownedByPrimary) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.ownedByPrimaryAccount,
        child: Icon(Icons.check, size: iconSize, color: Colors.white),
      );
    }
    if (ownedBySecondary) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.ownedBySecondaryAccount,
        child: Icon(
          Icons.arrow_upward,
          size: iconSize,
          color: AppColors.onOwnedBySecondaryAccount,
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.black45,
      child: Icon(Icons.add, size: iconSize, color: Colors.white),
    );
  }
}