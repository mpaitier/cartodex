import 'package:drift/drift.dart';

/// Table Drift du référentiel des cartes, alimentée depuis TCGdex.
///
/// [types] est stocké sous forme de chaîne, les valeurs étant
/// séparées par une virgule : une carte n'a jamais plus de
/// quelques types, une vraie table relationnelle serait
/// disproportionnée ici.
///
/// Le nom de la classe générée est explicitement fixé à [CardRow]
/// pour éviter toute ambiguïté avec l'entité domaine `PokemonCard`
/// et avec le widget Material `Card`.
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get localId => text()();
  TextColumn get name => text()();

  /// Nom brut de la catégorie (voir `CardCategory` côté domaine),
  /// converti dans la couche data.
  TextColumn get category => text()();

  TextColumn get setId => text()();
  TextColumn get setName => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get rarity => text().nullable()();
  IntColumn get hp => integer().nullable()();
  TextColumn get types => text().withDefault(const Constant(''))();
  TextColumn get illustrator => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}