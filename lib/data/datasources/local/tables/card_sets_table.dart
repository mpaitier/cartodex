import 'package:drift/drift.dart';

/// Table Drift du référentiel des sets de cartes, alimentée depuis
/// `pokemon-tcg-pocket-database`.
///
/// Le nom de la classe générée est explicitement fixé à
/// [CardSetRow] (plutôt que le "CardSet" que Drift déduirait par
/// défaut) pour garder une frontière visuelle claire avec
/// l'entité domaine `CardSet`.
@DataClassName('CardSetRow')
class CardSets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get totalCardCount => integer()();

  /// Clé de série de la source (ex: "A", "B") — voir
  /// `CardSet.seriesId`.
  TextColumn get seriesId => text()();

  TextColumn get logoUrl => text().nullable()();
  IntColumn get officialCardCount => integer().nullable()();

  /// Boosters disponibles pour ce set (ex: "Charizard,Mewtwo,Pikachu").
  TextColumn get packs => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}