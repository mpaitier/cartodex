import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Le "Σ" qui représente toutes les raretés à la fois, à côté des
/// images officielles du losange et de l'étoile (`RaritySymbol`).
///
/// Le jeu n'a pas d'image pour "toutes les raretés" : la lettre est
/// dessinée en texte, avec une hauteur alignée sur celle des images
/// ([size]) pour que les trois symboles s'alignent dans une même
/// rangée. Sans [color], elle prend la couleur du texte environnant.
class RarityTotalSymbol extends StatelessWidget {
  const RarityTotalSymbol({this.size = 12, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.rarityAll,
      excludeSemantics: true,
      child: SizedBox(
        height: size,
        child: Center(
          widthFactor: 1,
          child: Text(
            'Σ',
            style: TextStyle(
              fontSize: size * 1.15,
              height: 1,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
