/// Constantes globales de l'application, centralisées ici pour
/// éviter les chaînes de caractères éparpillées dans le code.
abstract class AppConstants {

  static const String pocketDatabaseBaseUrl =
      'https://cdn.jsdelivr.net/npm/pokemon-tcg-pocket-database/dist';

  /// Même référentiel, lu directement sur la branche `main` de son
  /// dépôt GitHub (toujours via jsDelivr). Utilisé seulement pour
  /// `cards.extra.json` : la version publiée sur npm (2.13.1) s'arrête
  /// à B1a, alors que le dépôt couvre toutes les extensions depuis le
  /// 02/11/2026. À retirer quand une version npm à jour sera publiée.
  static const String pocketDatabaseGithubBaseUrl =
      'https://cdn.jsdelivr.net/gh/flibustier/pokemon-tcg-pocket-database@main/dist';

  /// Images de cartes, hébergées par pocketcards.net (voir
  /// [PocketCardsImageSlug][../utils/pocket_cards_image_slug.dart]
  /// pour la conversion nom → slug de fichier).
  static const String pocketCardsImageBaseUrl =
      'https://pocketcards.net/images/cards';

  /// Logos de set, même source.
  static const String pocketCardsSetImageBaseUrl =
      'https://pocketcards.net/images/sets';

  /// Icônes de booster, même source.
  static const String pocketCardsBoosterImageBaseUrl =
      'https://pocketcards.net/images/boosters';

  static const String databaseFileName = 'cartodex.sqlite';
}