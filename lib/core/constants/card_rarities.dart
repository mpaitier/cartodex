import 'package:equatable/equatable.dart';

/// Groupe visuel d'une rareté TCG Pocket.
enum RarityGroup { diamond, star, crown, shiny }

/// Représentation visuelle d'une rareté (symbole + palier), déduite
/// du code brut renvoyé par la source (`C`, `SR`, `UR`...).
///
/// TCG Pocket affiche ses raretés avec ses propres symboles —
/// losanges, étoiles, couronne, étoiles chromatiques — plutôt
/// qu'avec les codes bruts de `pokemon-tcg-pocket-database`. Cette
/// classe centralise la conversion pour que la tuile de carte
/// (`CardGridItem`) et le filtre (`RarityFilterBar`) restent
/// cohérents sans dupliquer la table de correspondance.
///
/// Table tirée de `rarities.json`
/// (https://github.com/flibustier/pokemon-tcg-pocket-database/blob/main/dist/rarities.json) :
/// `SR` (Super Rare) et `SAR` (Special Art Rare) y partagent le même
/// palier (2 étoiles) — visuellement indissociables dans le jeu,
/// seule la bordure (non reproduite ici) les distingue.
class CardRarity extends Equatable {
  const CardRarity(this.group, this.tier);

  final RarityGroup group;

  /// Palier au sein du groupe : 1 à 4 pour les losanges, 1 à 3 pour
  /// les étoiles, 1 pour la couronne, 1 à 2 pour les étoiles
  /// chromatiques.
  final int tier;

  /// Le symbole répété [tier] fois (ex: "◆◆" pour un losange de
  /// palier 2). La couronne n'a qu'un seul palier.
  String get symbol {
    final char = switch (group) {
      RarityGroup.diamond => '◆',
      RarityGroup.star => '★',
      RarityGroup.crown => '♛',
      RarityGroup.shiny => '✷',
    };
    return group == RarityGroup.crown ? char : char * tier;
  }

  static const Map<String, CardRarity> _byCode = {
    'C': CardRarity(RarityGroup.diamond, 1),
    'U': CardRarity(RarityGroup.diamond, 2),
    'R': CardRarity(RarityGroup.diamond, 3),
    'RR': CardRarity(RarityGroup.diamond, 4),
    'AR': CardRarity(RarityGroup.star, 1),
    'SR': CardRarity(RarityGroup.star, 2),
    'SAR': CardRarity(RarityGroup.star, 2),
    'IM': CardRarity(RarityGroup.star, 3),
    'UR': CardRarity(RarityGroup.crown, 1),
    'S': CardRarity(RarityGroup.shiny, 1),
    'SSR': CardRarity(RarityGroup.shiny, 2),
  };

  /// La rareté visuelle correspondant à [code] (`PokemonCard.rarity`
  /// brut), ou `null` si absente ou inconnue — certaines cartes
  /// promo n'ont pas de rareté.
  static CardRarity? fromCode(String? code) => _byCode[code];

  /// Vrai si [code] correspond à la "collection de base" (rareté
  /// losange). Toute carte qui ne l'est pas — étoile, couronne,
  /// chromatique, ou sans rareté connue (certaines promos) — est
  /// considérée "alternative" : point d'entrée unique pour cette
  /// distinction, utilisée à la fois par `SetDetailState` (les
  /// compteurs) et `CardGridPager` (les volets swipeables), pour
  /// qu'ils s'accordent toujours.
  static bool isBase(String? code) => fromCode(code)?.group == RarityGroup.diamond;

  /// Les 10 paliers visuels distincts, du plus commun au plus rare,
  /// pour peupler le filtre — indépendamment des codes bruts qui
  /// peuvent s'y superposer (`SR`/`SAR`).
  static const List<CardRarity> allTiers = [
    CardRarity(RarityGroup.diamond, 1),
    CardRarity(RarityGroup.diamond, 2),
    CardRarity(RarityGroup.diamond, 3),
    CardRarity(RarityGroup.diamond, 4),
    CardRarity(RarityGroup.star, 1),
    CardRarity(RarityGroup.star, 2),
    CardRarity(RarityGroup.star, 3),
    CardRarity(RarityGroup.crown, 1),
    CardRarity(RarityGroup.shiny, 1),
    CardRarity(RarityGroup.shiny, 2),
  ];

  @override
  List<Object?> get props => [group, tier];
}