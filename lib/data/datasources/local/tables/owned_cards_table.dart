import 'package:drift/drift.dart';

/// Table Drift de la possession des cartes.
///
/// Volontairement séparée de [Cards][cards_table.dart] : elle ne
/// dépend jamais du contenu du référentiel et survit à une
/// resynchronisation complète du catalogue.
@DataClassName('OwnedCardRow')
class OwnedCards extends Table {
  TextColumn get cardId => text()();

  @override
  Set<Column> get primaryKey => {cardId};
}