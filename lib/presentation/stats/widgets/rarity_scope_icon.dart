import 'package:flutter/material.dart';

import '../../../core/widgets/rarity_symbol.dart';
import '../../../core/widgets/rarity_total_symbol.dart';
import '../../../domain/entities/rarity_scope.dart';
import '../../../l10n/l10n.dart';

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

  /// Nom du périmètre dans la langue de l'app ("toutes les raretés",
  /// "losanges", "étoiles").
  static String labelFor(AppLocalizations l10n, RarityScope scope) {
    switch (scope) {
      case RarityScope.all:
        return l10n.rarityAll;
      case RarityScope.diamond:
        return l10n.rarityDiamonds;
      case RarityScope.star:
        return l10n.rarityStars;
    }
  }

  /// Tooltip des boutons qui font tourner le périmètre (ex: "Raretés :
  /// losanges").
  static String tooltipFor(AppLocalizations l10n, RarityScope scope) {
    return l10n.rarityScopeTooltip(labelFor(l10n, scope));
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
