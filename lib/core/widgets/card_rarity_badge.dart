import 'package:flutter/material.dart';

import '../constants/card_rarities.dart';
import '../theme/app_colors.dart';
import 'card_rarity_icon.dart';

/// La rareté d'une carte ([CardRarityIcon]) posée sur un petit fond
/// gris aux bords arrondis.
///
/// Les symboles officiels sont blancs cerclés de noir : sur le fond
/// clair d'une tuile de carte, l'intérieur blanc disparaît et seuls
/// les contours restent visibles. Le fond gris
/// ([AppColors.rarityBadgeBackground], opacité de 80 %) leur rend leur
/// contraste.
///
/// Utilisé par `CardGridItem`. Les puces du filtre de rareté gardent
/// [CardRarityIcon] seul : elles ont déjà leur propre fond.
class CardRarityBadge extends StatelessWidget {
  const CardRarityBadge({required this.rarity, this.size = 10, super.key});

  final CardRarity rarity;

  /// Hauteur des symboles ; marges et arrondi du fond en découlent.
  final double size;

  static const double _backgroundOpacity = 0.8;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.rarityBadgeBackground.withValues(
          alpha: _backgroundOpacity,
        ),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size * 0.4,
          vertical: size * 0.2,
        ),
        child: CardRarityIcon(rarity: rarity, size: size),
      ),
    );
  }
}
