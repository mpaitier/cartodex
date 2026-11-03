import 'package:flutter/material.dart';

import '../../../core/widgets/rarity_symbol.dart';
import '../../../core/widgets/rarity_total_symbol.dart';
import '../../../domain/entities/rarity_scope.dart';

/// Le symbole d'un périmètre de raretés : Σ pour toutes les raretés,
/// puis les images officielles du losange et de l'étoile.
///
/// Partagé par le bouton de la top bar des statistiques
/// (`RarityScopeAction`) et par celui du bandeau de série de
/// l'accueil, pour que le cycle Σ → ◆ → ★ se lise de la même façon
/// partout. [totalColor] ne s'applique qu'au Σ : les images gardent
/// leurs couleurs d'origine.
class RarityScopeIcon extends StatelessWidget {
  const RarityScopeIcon({
    required this.scope,
    this.size = 20,
    this.totalColor,
    super.key,
  });

  final RarityScope scope;
  final double size;
  final Color? totalColor;

  /// Nom du périmètre, pour les tooltips.
  static String labelFor(RarityScope scope) {
    switch (scope) {
      case RarityScope.all:
        return 'toutes les raretés';
      case RarityScope.diamond:
        return 'losanges';
      case RarityScope.star:
        return 'étoiles';
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (scope) {
      case RarityScope.all:
        return RarityTotalSymbol(size: size, color: totalColor);
      case RarityScope.diamond:
        return RaritySymbol.diamond(size: size);
      case RarityScope.star:
        return RaritySymbol.star(size: size);
    }
  }
}
