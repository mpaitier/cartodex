/// Correspondance entre les codes de rareté des cartes
/// (`PokemonCard.rarity`) et ceux des probabilités de tirage
/// (`SlotPullRates.rateByRarity`).
///
/// Les deux fichiers de la source ne découpent pas les raretés de la
/// même façon :
/// - `pullRates.json` ne connaît pas "SAR" : les Special Art Rare se
///   tirent dans le même lot que les "SR" (les deux ont deux étoiles,
///   voir `CardRarity`) ;
/// - les boosters Deluxe ont des emplacements "CF", "UF", "RF" : une
///   version brillante d'une carte "C", "U" ou "R". Pour la
///   collection, c'est la même carte.
///
/// [normalize] ramène les deux côtés sur une clé commune, pour que le
/// pool de cartes et les probabilités se comparent sans écart.
abstract class PullRateRarity {
  /// Codes de cartes rangés sous un autre code dans les probabilités.
  static const Map<String, String> _aliases = {
    'SAR': 'SR',
    'CF': 'C',
    'UF': 'U',
    'RF': 'R',
  };

  /// La clé commune de [code], ou `null` pour une carte sans rareté
  /// (certaines promos), qui ne se tire jamais dans un booster.
  static String? normalize(String? code) {
    if (code == null) return null;
    return _aliases[code] ?? code;
  }
}
