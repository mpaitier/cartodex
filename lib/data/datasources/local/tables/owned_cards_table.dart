import 'package:drift/drift.dart';

/// Table Drift de la possession des cartes.
///
/// Une ligne = "ce compte possède cette carte" : la possession est
/// désormais par compte, pas globale, pour permettre à chacun de
/// suivre sa propre collection (voir [Accounts][accounts_table.dart]).
/// Volontairement séparée de [Cards][cards_table.dart] : elle ne
/// dépend jamais du contenu du référentiel et survit à une
/// resynchronisation complète du catalogue.
@DataClassName('OwnedCardRow')
class OwnedCards extends Table {
  TextColumn get cardId => text()();
  IntColumn get accountId => integer()();

  @override
  Set<Column> get primaryKey => {cardId, accountId};
}