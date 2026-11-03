import 'package:flutter/material.dart';

import '../constants/card_rarities.dart';
import '../constants/rarity_assets.dart';

/// Symbole officiel d'un groupe de rareté (losange, étoile, couronne,
/// étoile chromatique), répété [count] fois côte à côte — comme sur
/// les cartes du jeu ("◆◆◆" pour une rareté à trois losanges).
///
/// [size] fixe la hauteur de chaque image ; la largeur suit les
/// proportions du fichier (le losange est plus haut que large, la
/// couronne plus large que haute).
///
/// Composant de base des autres affichages de rareté :
/// `CardRarityIcon` pour la rareté d'une carte, et les compteurs ◆ / ★
/// de l'accueil, du détail d'un set et des comptes.
class RaritySymbol extends StatelessWidget {
  const RaritySymbol({
    required this.group,
    this.count = 1,
    this.size = 12,
    this.semanticLabel,
    super.key,
  });

  /// Losange seul : la "collection de base".
  const RaritySymbol.diamond({
    double size = 12,
    String? semanticLabel = 'losanges',
    Key? key,
  }) : this(
          group: RarityGroup.diamond,
          size: size,
          semanticLabel: semanticLabel,
          key: key,
        );

  /// Étoile seule : les cartes "alternatives" (étoile, couronne,
  /// chromatique).
  const RaritySymbol.star({
    double size = 12,
    String? semanticLabel = 'étoiles',
    Key? key,
  }) : this(
          group: RarityGroup.star,
          size: size,
          semanticLabel: semanticLabel,
          key: key,
        );

  final RarityGroup group;

  /// Nombre de répétitions de l'image, au moins 1.
  final int count;

  final double size;

  /// Libellé lu par les lecteurs d'écran à la place des images.
  final String? semanticLabel;

  /// Petit écart entre deux images répétées, proportionnel à la
  /// taille pour rester lisible de la puce de filtre à la tuile de
  /// carte.
  double get _gap => size / 8;

  @override
  Widget build(BuildContext context) {
    final asset = RarityAssets.forGroup(group);
    final repeat = count < 1 ? 1 : count;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < repeat; i++) ...[
            if (i > 0) SizedBox(width: _gap),
            Image.asset(
              asset,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ],
        ],
      ),
    );
  }
}
