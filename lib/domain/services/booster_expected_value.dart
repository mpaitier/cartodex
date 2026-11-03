import '../entities/pokemon_card.dart';
import '../entities/set_pull_rates.dart';
import 'pull_rate_rarity.dart';

/// Calcule combien de cartes "utiles" un booster rapporte en moyenne
/// à chaque ouverture : l'espérance du nombre de cartes manquantes
/// tirées.
///
/// Pour chaque variante de booster (normal, rare, +1...) et chaque
/// emplacement, la probabilité d'obtenir une carte précise de rareté
/// R vaut `p(R) / n(R)`, où `p(R)` est la probabilité de la rareté R
/// sur cet emplacement et `n(R)` le nombre de cartes de rareté R dans
/// le pool du booster (les cartes d'une même rareté ont toutes la
/// même chance de sortir). Sommer sur les cartes manquantes donne
/// `p(R) × m(R) / n(R)`, avec `m(R)` le nombre de cartes manquantes
/// de rareté R. Le total est pondéré par la probabilité d'apparition
/// de chaque variante.
///
/// Plus la valeur est haute, plus ouvrir ce booster a de chances de
/// compléter la collection : c'est le critère de tri des "boosters à
/// ouvrir en priorité". Une carte qui sortirait deux fois dans le
/// même booster compte deux fois ; à ces probabilités-là, l'écart
/// avec le nombre de cartes distinctes est négligeable.
///
/// Fonction pure, sans état ni accès aux données : testable seule,
/// et appelée par `GetCollectionStats` une fois les cartes et les
/// probabilités chargées.
class BoosterExpectedValue {
  const BoosterExpectedValue();

  /// Espérance de cartes manquantes par ouverture du booster dont le
  /// pool est [boosterCards], selon [pullRates].
  ///
  /// [boosterCards] doit contenir tout le pool du booster, raretés
  /// hors périmètre comprises : c'est lui qui donne `n(R)`. Seules
  /// les cartes pour lesquelles [isWanted] répond vrai entrent dans
  /// `m(R)`.
  double compute({
    required SetPullRates pullRates,
    required Iterable<PokemonCard> boosterCards,
    required bool Function(PokemonCard card) isWanted,
  }) {
    final poolByRarity = <String, int>{};
    final wantedByRarity = <String, int>{};
    for (final card in boosterCards) {
      final rarity = PullRateRarity.normalize(card.rarity);
      if (rarity == null) continue;
      poolByRarity[rarity] = (poolByRarity[rarity] ?? 0) + 1;
      if (isWanted(card)) {
        wantedByRarity[rarity] = (wantedByRarity[rarity] ?? 0) + 1;
      }
    }
    if (wantedByRarity.isEmpty) return 0;

    var expected = 0.0;
    for (final variant in pullRates.variants) {
      var perVariant = 0.0;
      for (final slot in variant.slots) {
        for (final entry in slot.rateByRarity.entries) {
          final rarity = PullRateRarity.normalize(entry.key);
          final pool = poolByRarity[rarity];
          final wanted = wantedByRarity[rarity];
          // Une rareté sans carte dans ce booster (ex: un emplacement
          // chromatique dans un booster qui n'en contient pas) ne
          // rapporte rien.
          if (pool == null || wanted == null) continue;
          perVariant += entry.value * wanted / pool;
        }
      }
      expected += variant.appearanceRate * perVariant;
    }
    return expected;
  }
}
