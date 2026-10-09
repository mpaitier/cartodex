/// Construit les "slugs" utilisés par pocketcards.net
/// (https://pocketcards.net) pour nommer ses fichiers d'image : cartes,
/// logos de set, et boosters.
///
/// Site non-officiel, sans API documentée : la conversion générique
/// ([_slugify]) est déduite d'exemples observés, pas d'une spécification
/// garantie. Exemples ayant servi de base :
/// - "Volbeat" (carte) → "volbeat"
/// - "Team Rocket's Moltres ex" (carte) → "team-rockets-moltres-ex"
/// - "Porygon2" (carte) → "porygon-2"
/// - "Nidoran♀" (carte) → "nidoran-f"
/// - "Ruler of the Skies" (set) → "ruler-of-the-skies"
/// - "Genetic Apex" + "Mewtwo" (booster) → "genetic-apex-mewtwo"
/// - "Mega Rising" + "Mega Blaziken" (booster) → "mega-rising-blaziken"
///
/// Elle peut donc échouer sur des noms à ponctuation inhabituelle (ex:
/// "Mr. Mime", accents...), ou sur des erreurs de saisie présentes dans
/// le référentiel distant lui-même. Quatre cas récurrents sont traités
/// directement dans [_slugify] :
/// - deux mots concaténés sans espace mais séparés par une majuscule
///   (ex: "Teal MaskOgerpon") ;
/// - un préfixe de forme régionale collé au nom du Pokémon, sans
///   même de majuscule pour le signaler (ex: "Galarianzigzagoon",
///   tout en minuscules) — voir [_regionalFormPrefixes] ;
/// - un chiffre collé à la fin d'un nom, que le site sépare par un
///   tiret (ex: "Porygon2" → "porygon-2") ;
/// - un symbole de genre en fin de nom, que le site écrit sous forme
///   de lettre (♀ → "f", ♂ → "m") — voir [_genderSymbolSuffixes].
///
/// Pour tout autre cas non couvert, voir [_cardSlugOverrides]
/// ci-dessous et [AppLogger][../utils/app_logger.dart] côté widgets,
/// qui signale chaque échec de chargement pour les repérer au fil de
/// l'utilisation plutôt que de les découvrir en silence.
abstract class PocketCardsImageSlug {
  /// Préfixes de forme régionale connus, parfois collés directement
  /// au nom du Pokémon dans le référentiel distant sans espace ni
  /// majuscule pour marquer la coupure (ex: "Galarianzigzagoon" au
  /// lieu de "Galarian Zigzagoon") — la casse ne permettant pas de
  /// détecter ces cas comme le fait le découpage camelCase plus bas,
  /// ils sont listés explicitement. Comparaison insensible à la
  /// casse dans [_insertMissingRegionalFormSpace].
  static const List<String> _regionalFormPrefixes = [
    'Galarian',
    'Alolan',
    'Hisuian',
    'Paldean',
  ];

  /// Correspondance entre les symboles de genre du référentiel distant
  /// et le suffixe utilisé par pocketcards.net (ex: "Nidoran♀" →
  /// "nidoran-f"). Sans cette table, le symbole serait traité comme
  /// une ponctuation quelconque et disparaîtrait, laissant "nidoran"
  /// seul (404). Le suffixe "m" pour ♂ est déduit par symétrie avec
  /// "f" : à confirmer sur une carte Nidoran♂ réelle.
  static const Map<String, String> _genderSymbolSuffixes = {
    '♀': 'f',
    '♂': 'm',
  };

  /// Préfixe des noms de booster du set "Mega Rising" (ex: "Mega
  /// Blaziken"), absent du nom de fichier correspondant sur
  /// pocketcards.net — voir [fromBoosterName].
  static const String _boosterMegaPrefix = 'Mega ';

  /// Corrections manuelles pour les cartes dont le nom brut du
  /// référentiel distant ne donne toujours pas le bon slug une fois
  /// passé par [_slugify] (y compris ses règles de découpage) —
  /// réservé aux erreurs de saisie qu'aucune règle générique ne
  /// couvre. Clé : id de la carte tel que construit par
  /// `CardModel.fromJson` (`<setId>-<numéro>`, ex: "B4-19").
  static const Map<String, String> _cardSlugOverrides = {};

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

  /// Le slug d'icône pour un booster : pocketcards.net préfixe le nom
  /// du booster par celui de son set (ex: set "Genetic Apex", booster
  /// "Mewtwo" → "genetic-apex-mewtwo"), le nom du booster seul
  /// ("mewtwo") ne correspondant à aucun fichier.
  ///
  /// Les boosters de "Mega Rising" s'appellent "Mega Blaziken",
  /// "Mega Altaria"... dans le référentiel distant, mais le fichier
  /// est "mega-rising-blaziken" : le "Mega " de tête du nom de
  /// booster est retiré avant l'assemblage, sans quoi le slug
  /// contiendrait "mega" deux fois ("mega-rising-mega-blaziken", 404).
  static String fromBoosterName(String setName, String packName) {
    final cleanedPackName = packName.startsWith(_boosterMegaPrefix)
        ? packName.substring(_boosterMegaPrefix.length)
        : packName;
    return _slugify('$setName $cleanedPackName');
  }

  static String _slugify(String raw) {
    final withGenderLetters = _replaceGenderSymbols(raw);
    final withRegionalFormSpace =
        _insertMissingRegionalFormSpace(withGenderLetters);
    // Le référentiel distant concatène aussi parfois deux mots sans
    // espace tout en gardant une majuscule pour marquer la coupure
    // (ex: "Teal MaskOgerpon") : on la réinsère avant toute majuscule
    // précédée d'une minuscule ou d'un chiffre, avant la mise en
    // minuscule qui la rendrait indétectable.
    final camelSpaced = withRegionalFormSpace.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    );
    // pocketcards.net sépare par un tiret un chiffre collé à la fin
    // d'un nom (ex: "Porygon2" → "porygon-2", et non "porygon2" qui
    // renvoie un 404) : on insère un espace entre une minuscule et un
    // chiffre, normalisé en tiret plus bas comme les autres espaces.
    final spaced = camelSpaced.replaceAllMapped(
      RegExp(r'([a-z])(\d)'),
      (match) => '${match[1]} ${match[2]}',
    );
    final lowerCased = spaced.toLowerCase();
    // Les apostrophes sont supprimées, pas remplacées par un tiret
    // (ex: "rocket's" → "rockets", pas "rocket-s").
    final withoutApostrophes = lowerCased.replaceAll(RegExp("['’]"), '');
    // Tout ce qui n'est ni lettre/chiffre ni espace/tiret devient un
    // espace, pour être normalisé en un seul tiret juste après
    // (accents, ponctuation...).
    final normalized = withoutApostrophes.replaceAll(
      RegExp(r'[^a-z0-9\s-]'),
      ' ',
    );
    return normalized.trim().replaceAll(RegExp(r'[\s-]+'), '-');
  }

  /// Remplace chaque symbole de [_genderSymbolSuffixes] par un espace
  /// suivi de sa lettre (ex: "Nidoran♀" → "Nidoran f"), pour que la
  /// normalisation en tiret fasse le reste ("nidoran-f"). À appeler
  /// avant tout le reste de [_slugify] : le filtre de ponctuation
  /// final supprimerait sinon le symbole sans laisser de trace.
  static String _replaceGenderSymbols(String raw) {
    var result = raw;
    _genderSymbolSuffixes.forEach((symbol, letter) {
      result = result.replaceAll(symbol, ' $letter');
    });
    return result;
  }

  /// Si [raw] commence par l'un de [_regionalFormPrefixes] (insensible
  /// à la casse) immédiatement suivi d'une lettre — donc sans espace
  /// ni tiret entre le préfixe et le nom du Pokémon — insère un
  /// espace à cet endroit. Sans effet si le préfixe est déjà séparé
  /// (espace, tiret) ou absent.
  static String _insertMissingRegionalFormSpace(String raw) {
    for (final prefix in _regionalFormPrefixes) {
      if (raw.length <= prefix.length) continue;
      final startsWithPrefix =
          raw.substring(0, prefix.length).toLowerCase() ==
              prefix.toLowerCase();
      if (!startsWithPrefix) continue;
      final nextChar = raw[prefix.length];
      if (RegExp(r'[A-Za-z]').hasMatch(nextChar)) {
        return '${raw.substring(0, prefix.length)} ${raw.substring(prefix.length)}';
      }
      return raw;
    }
    return raw;
  }
}