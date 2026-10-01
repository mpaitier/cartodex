import '../../core/constants/card_rarities.dart';

/// Périmètre de raretés pris en compte par les statistiques.
///
/// - [all] : toutes les cartes, raretés confondues (défaut) ;
/// - [diamond] : uniquement la "collection de base" (rareté losange) ;
/// - [star] : uniquement les cartes "alternatives" (étoile, couronne,
///   chromatique, ou sans rareté connue).
///
/// Le partage losange / alternatif s'appuie sur [CardRarity.isBase],
/// le même point d'entrée que le détail d'un set et la progression
/// des tuiles, pour que tous les écrans s'accordent.
enum RarityScope {
  all,
  diamond,
  star;

  /// Vrai si une carte de rareté brute [rarityCode] entre dans ce
  /// périmètre.
  bool includes(String? rarityCode) {
    switch (this) {
      case RarityScope.all:
        return true;
      case RarityScope.diamond:
        return CardRarity.isBase(rarityCode);
      case RarityScope.star:
        return !CardRarity.isBase(rarityCode);
    }
  }

  /// Périmètre suivant dans le cycle rond → losange → étoile → rond.
  RarityScope get next {
    return RarityScope.values[(index + 1) % RarityScope.values.length];
  }
}