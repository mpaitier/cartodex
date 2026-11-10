import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
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
  }) : _useGroupLabel = false;

  /// Losange seul : la "collection de base". Sans [semanticLabel], les
  /// lecteurs d'écran annoncent "losanges" dans la langue de l'app.
  const RaritySymbol.diamond({
    double size = 12,
    String? semanticLabel,
    Key? key,
  }) : this._single(
          group: RarityGroup.diamond,
          size: size,
          semanticLabel: semanticLabel,
          key: key,
        );

  /// Étoile seule : les cartes "alternatives" (étoile, couronne,
  /// chromatique). Sans [semanticLabel], les lecteurs d'écran
  /// annoncent "étoiles" dans la langue de l'app.
  const RaritySymbol.star({
    double size = 12,
    String? semanticLabel,
    Key? key,
  }) : this._single(
          group: RarityGroup.star,
          size: size,
          semanticLabel: semanticLabel,
          key: key,
        );

  /// Symbole unique, avec le libellé traduit du groupe par défaut
  /// (voir [_defaultLabel]). Le texte traduit dépend du `BuildContext` :
  /// il ne peut être résolu qu'au moment du `build`, d'où ce drapeau
  /// plutôt qu'une valeur par défaut du paramètre.
  const RaritySymbol._single({
    required this.group,
    required this.size,
    this.semanticLabel,
    super.key,
  })  : count = 1,
        _useGroupLabel = true;

  final RarityGroup group;

  /// Nombre de répétitions de l'image, au moins 1.
  final int count;

  final double size;

  /// Libellé lu par les lecteurs d'écran à la place des images.
  final String? semanticLabel;

  /// Vrai pour [RaritySymbol.diamond] et [RaritySymbol.star] : sans
  /// [semanticLabel], le nom du groupe est lu à la place.
  final bool _useGroupLabel;

  /// Nom traduit du groupe ("losanges", "étoiles"), ou `null` pour les
  /// groupes qui n'ont pas de constructeur dédié.
  String? _defaultLabel(BuildContext context) {
    switch (group) {
      case RarityGroup.diamond:
        return context.l10n.rarityDiamonds;
      case RarityGroup.star:
        return context.l10n.rarityStars;
      case RarityGroup.crown:
      case RarityGroup.shiny:
        return null;
    }
  }

  /// Petit écart entre deux images répétées, proportionnel à la
  /// taille pour rester lisible de la puce de filtre à la tuile de
  /// carte.
  double get _gap => size / 8;

  @override
  Widget build(BuildContext context) {
    final asset = RarityAssets.forGroup(group);
    final repeat = count < 1 ? 1 : count;
    final label = semanticLabel ??
        (_useGroupLabel ? _defaultLabel(context) : null);
    return Semantics(
      label: label,
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
