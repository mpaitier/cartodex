import '../../../core/constants/card_rarities.dart';
import '../../../domain/entities/rarity_scope.dart';

/// Correspondance entre le périmètre de raretés global
/// ([RarityScope]) et les volets du détail d'un set
/// ([CardGroupFilter], un volet par page de `CardGridPager`).
///
/// Les deux découpent les cartes de la même façon
/// ([CardRarity.isBase]) : Σ = volet du milieu (toutes les cartes),
/// losange = volet de gauche, étoile = volet de droite.
extension RarityScopeCardGroup on RarityScope {
  CardGroupFilter get cardGroup {
    switch (this) {
      case RarityScope.all:
        return CardGroupFilter.all;
      case RarityScope.diamond:
        return CardGroupFilter.diamond;
      case RarityScope.star:
        return CardGroupFilter.nonDiamond;
    }
  }
}

/// Sens inverse de [RarityScopeCardGroup] : le périmètre global qui
/// correspond au volet affiché.
extension CardGroupRarityScope on CardGroupFilter {
  RarityScope get rarityScope {
    switch (this) {
      case CardGroupFilter.all:
        return RarityScope.all;
      case CardGroupFilter.diamond:
        return RarityScope.diamond;
      case CardGroupFilter.nonDiamond:
        return RarityScope.star;
    }
  }
}
