/// Construit les "slugs" utilisés par pocketcards.net
/// (https://pocketcards.net) pour nommer ses fichiers d'image : cartes,
/// logos de set, et boosters.
///
/// Site non-officiel, sans API documentée : la conversion générique
/// ([_slugify]) est déduite d'exemples observés, pas d'une spécification
/// garantie. Exemples ayant servi de base :
/// - "Volbeat" (carte) → "volbeat"
/// - "Team Rocket's Moltres ex" (carte) → "team-rockets-moltres-ex"
/// - "Ruler of the Skies" (set / booster) → "ruler-of-the-skies"
/// - "Mega Rising Blaziken" (booster) → "mega-rising-blaziken"
///
/// Elle peut donc échouer sur des noms à ponctuation inhabituelle (ex:
/// "Mr. Mime", "Nidoran♀"/"Nidoran♂", accents...), ou sur des erreurs de
/// saisie présentes dans le référentiel distant lui-même (voir
/// [_cardSlugOverrides] ci-dessous) — voir
/// [AppLogger][../utils/app_logger.dart] côté widgets, qui signale chaque
/// échec de chargement pour repérer ces cas au fil de l'utilisation
/// plutôt que de les découvrir en silence.
abstract class PocketCardsImageSlug {
  /// Corrections manuelles pour les cartes dont le nom brut du
  /// référentiel distant ne donne pas le bon slug une fois passé par
  /// [_slugify] — typiquement une erreur de saisie dans la donnée
  /// source elle-même (espace manquant, etc.), pas un défaut de la
  /// conversion générique. Clé : id de la carte tel que construit par
  /// `CardModel.fromJson` (`<setId>-<numéro>`, ex: "B4-19").
  static const Map<String, String> _cardSlugOverrides = {
    // Référentiel distant : nom brut "Teal MaskOgerpon" (espace
    // manquant entre "Mask" et "Ogerpon"), repéré via le log d'échec
    // de chargement (AppLogger, niveau ERROR) sur la carte B4-19.
    'B4-19': 'teal-mask-ogerpon',
  };

  /// Le slug de carte pour [cardId] (`<setId>-<numéro>`, voir
  /// `CardModel.fromJson`) et son [name], sans le suffixe set/numéro
  /// (assemblé séparément avec le reste de l'URL). Vérifie d'abord
  /// [_cardSlugOverrides] avant de retomber sur la conversion
  /// générique — si le nom brut change d'une synchronisation à
  /// l'autre, une correction ici cesse simplement d'avoir d'effet
  /// plutôt que de casser silencieusement autre chose.
  static String fromCardName(String cardId, String name) {
    return _cardSlugOverrides[cardId] ?? _slugify(name);
  }

  /// Le slug de logo pour un nom de set (ex: "Ruler of the Skies" →
  /// "ruler-of-the-skies").
  static String fromSetName(String name) => _slugify(name);

  /// Le slug d'icône pour un nom de booster (ex: "Mega Rising
  /// Blaziken" → "mega-rising-blaziken"). Le nom brut du booster, tel
  /// que fourni par le référentiel distant (`CardSet.packs`), semble
  /// déjà correspondre exactement au nom attendu par pocketcards.net
  /// (aucune combinaison avec le nom du set ne s'est révélée
  /// nécessaire sur les exemples observés à ce jour).
  static String fromPackName(String name) => _slugify(name);

  static String _slugify(String raw) {
    final lowerCased = raw.toLowerCase();
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