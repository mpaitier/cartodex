import 'package:flutter/material.dart';

import '../constants/card_rarities.dart';
import 'rarity_symbol.dart';

/// La rareté d'une carte avec les images officielles du jeu : le
/// symbole de son groupe répété selon son palier (voir
/// [CardRarity.iconCount]).
///
/// Utilisée par la tuile de carte (`CardGridItem`) et par les puces du
/// filtre de rareté (`RarityFilterBar`), pour qu'elles affichent
/// toujours la même chose pour une même rareté.
class CardRarityIcon extends StatelessWidget {
  const CardRarityIcon({required this.rarity, this.size = 12, super.key});

  final CardRarity rarity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RaritySymbol(
      group: rarity.group,
      count: rarity.iconCount,
      size: size,
      semanticLabel: rarity.symbol,
    );
  }
}
