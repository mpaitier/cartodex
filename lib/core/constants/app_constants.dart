/// Constantes globales de l'application, centralisées ici pour
/// éviter les chaînes de caractères éparpillées dans le code.
abstract class AppConstants {
  /// Base URL de l'API TCGdex, utilisée pour synchroniser le
  /// référentiel des cartes disponibles dans TCG Pocket.
  static const String tcgdexBaseUrl = 'https://api.tcgdex.net/v2';

  /// Identifiant de la série TCG Pocket dans l'API TCGdex : toutes
  /// les cartes du jeu mobile y sont regroupées.
  static const String tcgPocketSeriesId = 'tcgp';

  /// Nom du fichier de la base de données locale Drift.
  static const String databaseFileName = 'cartodex.sqlite';
}
