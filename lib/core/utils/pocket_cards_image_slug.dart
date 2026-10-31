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
/// - "Ruler of the Skies" (set) → "ruler-of-the-skies"
/// - "Genetic Apex" + "Mewtwo" (booster) → "genetic-apex-mewtwo"
/// - "Mega Rising" + "Mega Blaziken" (booster) → "mega-rising-blaziken"
/// - "PROMO-B" (code de set dans le nom d'une carte) → "pb"
/// - "Pokémon Center Lady" (carte) → "pokemon-center-lady"
///
/// Elle peut donc échouer sur des noms à ponctuation inhabituelle (ex:
/// "Mr. Mime", "Nidoran♀"/"Nidoran♂"...), ou sur des erreurs de
/// saisie présentes dans le référentiel distant lui-même. Les lettres
/// accentuées sont ramenées à leur lettre de base (voir
/// [_removeDiacritics]), et trois autres cas récurrents sont traités
/// directement dans [_slugify] :
/// - deux mots concaténés sans espace mais séparés par une majuscule
///   (ex: "Teal MaskOgerpon") ;
/// - un préfixe de forme régionale collé au nom du Pokémon, sans
///   même de majuscule pour le signaler (ex: "Galarianzigzagoon",
///   tout en minuscules) — voir [_regionalFormPrefixes] ;
/// - un chiffre collé à la fin d'un nom, que le site sépare par un
///   tiret (ex: "Porygon2" → "porygon-2").
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

  /// Préfixe des noms de booster du set "Mega Rising" (ex: "Mega
  /// Blaziken"), absent du nom de fichier correspondant sur
  /// pocketcards.net — voir [fromBoosterName].
  static const String _boosterMegaPrefix = 'Mega ';

  /// Lettres accentuées et leur lettre de base, pour [_removeDiacritics].
  /// pocketcards.net écrit "pokemon" là où le nom porte "Pokémon" ;
  /// sans cette table, le "é" devenait un tiret ("pok-mon", 404).
  /// Couvre les accents latins courants : un caractère absent de la
  /// table reste traité comme de la ponctuation par [_slugify].
  static const Map<String, String> _diacritics = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', //
    'À': 'A', 'Á': 'A', 'Â': 'A', 'Ä': 'A', 'Ã': 'A', 'Å': 'A', //
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
    'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E', //
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', //
    'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I', //
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', //
    'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Ö': 'O', 'Õ': 'O', //
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', //
    'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U', //
    'ç': 'c', 'Ç': 'C', 'ñ': 'n', 'Ñ': 'N', //
  };

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

  /// Préfixe des codes de set promotionnels dans le référentiel
  /// distant (ex: "PROMO-A", "PROMO-B") — voir [fromSetCode].
  static const String _promoSetCodePrefix = 'PROMO-';

  /// Le segment de code de set dans le nom de fichier d'une carte.
  ///
  /// En général, simplement le code en minuscules ("A1" → "a1",
  /// "B2a" → "b2a"). Les promos font exception : le site les abrège
  /// en "p" suivi de la lettre de série ("PROMO-A" → "pa", "PROMO-B"
  /// → "pb"), d'après "pikachu-pa-015" et "psyduck-pb-008". Le
  /// code complet ("promo-b") renvoie un 404.
  static String fromSetCode(String setCode) {
    if (setCode.startsWith(_promoSetCodePrefix)) {
      final series = setCode.substring(_promoSetCodePrefix.length);
      return 'p${series.toLowerCase()}';
    }
    return setCode.toLowerCase();
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
    // En premier : les règles de découpage plus bas ne reconnaissent
    // que les lettres sans accent ([a-z], [A-Z]).
    final withoutDiacritics = _removeDiacritics(raw);
    final withRegionalFormSpace =
        _insertMissingRegionalFormSpace(withoutDiacritics);
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
    // (accents, ponctuation, symboles de genre...).
    final normalized = withoutApostrophes.replaceAll(
      RegExp(r'[^a-z0-9\s-]'),
      ' ',
    );
    return normalized.trim().replaceAll(RegExp(r'[\s-]+'), '-');
  }

  /// Remplace chaque lettre accentuée de [raw] par sa lettre de base
  /// (voir [_diacritics]), en gardant la casse : "Pokémon" →
  /// "Pokemon", "Éclair" → "Eclair".
  static String _removeDiacritics(String raw) {
    final buffer = StringBuffer();
    for (final char in raw.split('')) {
      buffer.write(_diacritics[char] ?? char);
    }
    return buffer.toString();
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