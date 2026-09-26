/// Construit le "slug" utilisé par pocketcards.net
/// (https://pocketcards.net) pour nommer ses fichiers d'image de
/// carte, à partir du nom de la carte.
///
/// Site non-officiel, sans API documentée : cette conversion est
/// déduite d'exemples observés, pas d'une spécification garantie.
/// Exemples ayant servi de base :
/// - "Volbeat" → "volbeat"
/// - "Team Rocket's Moltres ex" → "team-rockets-moltres-ex"
/// - "Team Rocket's Weezing ex" → "team-rockets-weezing-ex"
///
/// Elle peut donc échouer sur des noms à ponctuation inhabituelle
/// (ex: "Mr. Mime", "Nidoran♀"/"Nidoran♂", accents...) — voir
/// [AppLogger][../utils/app_logger.dart] côté widgets, qui signale
/// chaque échec de chargement pour repérer ces cas au fil de
/// l'utilisation plutôt que de les découvrir en silence.
abstract class PocketCardsImageSlug {
  /// Le slug pour [name], sans le suffixe set/numéro (voir
  /// `CardModel.fromJson`, qui l'assemble avec le reste de l'URL).
  static String fromCardName(String name) {
    final lowerCased = name.toLowerCase();
    // Les apostrophes sont supprimées, pas remplacées par un tiret
    // (ex: "rocket's" → "rockets", pas "rocket-s").
    final withoutApostrophes = lowerCased.replaceAll(RegExp("['’]"), '');
    // Tout ce qui n'est ni lettre/chiffre ni espace/tiret devient un
    // espace, pour être normalisé en un seul tiret juste après
    // (accents, ponctuation, symboles de genre...).
    final normalized = withoutApostrophes.replaceAll(
      RegExp(r'[^a-z0-9\s-]'),
      ' ',
    );
    return normalized.trim().replaceAll(RegExp(r'[\s-]+'), '-');
  }
}