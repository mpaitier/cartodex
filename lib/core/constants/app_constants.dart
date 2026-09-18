/// Constantes globales de l'application, centralisées ici pour
/// éviter les chaînes de caractères éparpillées dans le code.
abstract class AppConstants {
  /// Base des fichiers JSON du jeu de données `pokemon-tcg-pocket-database`
  /// (https://github.com/flibustier/pokemon-tcg-pocket-database), servis via
  /// jsDelivr. Fournit `sets.json`, `cards.json` et `cards.extra.json`.
  ///
  /// Remplace l'API TCGdex : celle-ci exposait un référentiel
  /// incomplet pour TCG Pocket (notamment la répartition des
  /// cartes par booster), là où ce jeu de données est maintenu
  /// spécifiquement pour ce jeu.
  static const String pocketDatabaseBaseUrl =
      'https://cdn.jsdelivr.net/npm/pokemon-tcg-pocket-database/dist';

  /// Nom du fichier de la base de données locale Drift.
  static const String databaseFileName = 'cartodex.sqlite';
}