/// Constantes globales de l'application, centralisées ici pour
/// éviter les chaînes de caractères éparpillées dans le code.
abstract class AppConstants {

  /// Référentiel publié sur npm, figé sur la version majeure 2 : sans
  /// numéro, jsDelivr servirait toujours la dernière version, et une
  /// 3.0 au format différent (réimpressions regroupées sous `sets`,
  /// proposé par le mainteneur) casserait la lecture des cartes dès la
  /// synchronisation suivante. `@2` reçoit les mises à jour 2.x, jamais
  /// la 3.0 : le passage à la 3 se fera par un changement explicite.
  static const String pocketDatabaseBaseUrl =
      'https://cdn.jsdelivr.net/npm/pokemon-tcg-pocket-database@2/dist';

  /// Même référentiel, lu directement sur la branche `main` de son
  /// dépôt GitHub (toujours via jsDelivr). Utilisé seulement pour
  /// `cards.extra.json`, seule source des cartes : la version publiée
  /// sur npm (2.13.1) s'arrête à B1a pour ce fichier, alors que le
  /// dépôt couvre toutes les extensions depuis le 02/11/2026. npm reste
  /// le repli si GitHub ne répond pas ou si le format du fichier n'est
  /// plus celui attendu (voir `CardRemoteDataSourceImpl.fetchAllCards`).
  /// Une branche ne peut pas être figée sur une version majeure, d'où
  /// ce contrôle de format côté data source.
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