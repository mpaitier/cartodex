import 'package:drift/drift.dart';

/// Table Drift du référentiel des sets de cartes, alimentée depuis
/// TCGdex.
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
  TextColumn get logoUrl => text().nullable()();
  IntColumn get officialCardCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
} 