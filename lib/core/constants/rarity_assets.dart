import 'card_rarities.dart';

/// Chemins des images officielles des symboles de rareté, embarquées
/// dans `assets/images/rarities/`.
///
/// Les fichiers viennent du dossier `dist/images/rarities` de
/// `pokemon-tcg-pocket-database`
/// (https://github.com/flibustier/pokemon-tcg-pocket-database), le
/// même référentiel que les cartes. Ils sont copiés dans l'app plutôt
/// que chargés à distance : quatre petites images, affichées partout
/// (tuiles, filtres, compteurs), qui doivent apparaître tout de suite,
/// même hors connexion.
abstract class RarityAssets {
  static const String _folder = 'assets/images/rarities';

  static const String diamond = '$_folder/diamond.png';
  static const String star = '$_folder/star.png';
  static const String crown = '$_folder/crown.png';
  static const String shinyStar = '$_folder/shiny-star.png';

  /// L'image d'un groupe de rareté.
  static String forGroup(RarityGroup group) {
    switch (group) {
      case RarityGroup.diamond:
        return diamond;
      case RarityGroup.star:
        return star;
      case RarityGroup.crown:
        return crown;
      case RarityGroup.shiny:
        return shinyStar;
    }
  }
}
