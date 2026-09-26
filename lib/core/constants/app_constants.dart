/// Constantes globales de l'application, centralisées ici pour
/// éviter les chaînes de caractères éparpillées dans le code.
abstract class AppConstants {

  static const String pocketDatabaseBaseUrl =
      'https://cdn.jsdelivr.net/npm/pokemon-tcg-pocket-database/dist';

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