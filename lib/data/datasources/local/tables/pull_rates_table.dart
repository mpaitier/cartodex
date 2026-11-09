import 'package:drift/drift.dart';

/// Table Drift des probabilités de tirage des boosters, alimentée
/// depuis `pullRates.json` de `pokemon-tcg-pocket-database`.
///
/// Une ligne = "dans le set [setId], pour la variante de booster
/// [packVariant], l'emplacement [slot] donne une carte de rareté
/// [rarity] avec la probabilité [rate]". La probabilité d'apparition
/// de la variante ([appearanceRate]) est répétée sur chacune de ses
/// lignes : quelques centaines de lignes en tout, une table séparée
/// pour une seule valeur par variante n'apporterait rien.
///
/// Les probabilités sont stockées en fractions (entre 0 et 1), déjà
/// converties depuis les pourcentages de la source.
///
/// Le nom de la classe générée est fixé à [PullRateRow] pour garder
/// une frontière claire avec les entités domaine (`SetPullRates`...).
@DataClassName('PullRateRow')
class PullRates extends Table {
  TextColumn get setId => text()();

  /// Nom de la variante dans la source (ex: "Regular Pack").
  TextColumn get packVariant => text()();

  RealColumn get appearanceRate => real()();

  /// Rang de l'emplacement dans le booster, à partir de 0.
  IntColumn get slot => integer()();

  /// Code de rareté brut de la source (ex: "SR", "CF").
  TextColumn get rarity => text()();

  RealColumn get rate => real()();

  @override
  Set<Column> get primaryKey => {setId, packVariant, slot, rarity};
}
