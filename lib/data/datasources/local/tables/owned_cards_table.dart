import 'package:drift/drift.dart';

/// Table Drift de la possession des cartes.
///
/// Une ligne = "ce compte possède cette carte" : la possession est
/// par compte, pas globale, pour permettre à chacun de suivre sa
/// propre collection (voir [Accounts][accounts_table.dart]).
/// Volontairement séparée de [Cards][cards_table.dart] : elle ne
/// dépend jamais du contenu du référentiel et survit à une
/// resynchronisation complète du catalogue.
///
/// [accountId] est une chaîne (UUID), au même titre que
/// [Accounts.id][accounts_table.dart] — voir sa documentation pour
/// la raison de ce choix (identifiants uniques globalement, pour
/// une synchronisation multi-appareils sans collision).
@DataClassName('OwnedCardRow')
class OwnedCards extends Table {
  TextColumn get cardId => text()();
  TextColumn get accountId => text()();

  @override
  Set<Column> get primaryKey => {cardId, accountId};
}