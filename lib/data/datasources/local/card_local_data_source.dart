import 'package:drift/drift.dart';

import '../../../core/error/exceptions.dart';
import '../../../domain/entities/card_category.dart';
import '../../models/card_model.dart';
import '../../models/card_set_model.dart';
import 'app_database.dart';

/// Accès à la base locale pour tout ce qui concerne les cartes.
///
/// Reste volontairement ignorant de la notion de `Failure` (qui
/// appartient au domaine) : lève des [CacheException] en cas
/// d'erreur, charge au repository de les convertir.
abstract class CardLocalDataSource {
  /// Remplace le contenu du référentiel de sets par [sets].
  Future<void> cacheCardSets(List<CardSetModel> sets);

  /// Remplace le contenu du référentiel de cartes d'un set par
  /// [cards].
  Future<void> cacheCards(String setId, List<CardModel> cards);

  Future<List<CardSetModel>> getCachedCardSets();

  Future<List<CardModel>> getCachedCardsBySet(String setId);

  /// Cartes possédées par le compte [accountId] uniquement : la
  /// possession n'est plus globale (voir [OwnedCards][tables/owned_cards_table.dart]).
  Future<Set<String>> getOwnedCardIds(String accountId);

  Future<void> setCardOwned({
    required String cardId,
    required String accountId,
    required bool owned,
  });
}

class CardLocalDataSourceImpl implements CardLocalDataSource {
  const CardLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> cacheCardSets(List<CardSetModel> sets) async {
    try {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.cardSets,
          sets.map(_setToCompanion).toList(),
        );
      });
    } on Exception catch (e) {
      throw CacheException('Échec de la mise en cache des sets : $e');
    }
  }

  @override
  Future<void> cacheCards(String setId, List<CardModel> cards) async {
    try {
      await _database.batch((batch) {
        batch.deleteWhere(_database.cards, (t) => t.setId.equals(setId));
        batch.insertAllOnConflictUpdate(
          _database.cards,
          cards.map(_cardToCompanion).toList(),
        );
      });
    } on Exception catch (e) {
      throw CacheException('Échec de la mise en cache des cartes : $e');
    }
  }

  @override
  Future<List<CardSetModel>> getCachedCardSets() async {
    try {
      final rows = await _database.select(_database.cardSets).get();
      // Sans colonne de date de sortie en local, on s'appuie sur
      // l'ordre d'insertion (proche de l'ordre chronologique de la
      // source) et on l'inverse : les sets les plus récents en
      // premier plutôt que les plus anciens.
      return rows.reversed.map(_setFromRow).toList();
    } on Exception catch (e) {
      throw CacheException('Échec de la lecture des sets en cache : $e');
    }
  }

  @override
  Future<List<CardModel>> getCachedCardsBySet(String setId) async {
    try {
      final query = _database.select(_database.cards)
        ..where((t) => t.setId.equals(setId));
      final rows = await query.get();
      return rows.map(_cardFromRow).toList();
    } on Exception catch (e) {
      throw CacheException('Échec de la lecture des cartes en cache : $e');
    }
  }

  @override
  Future<Set<String>> getOwnedCardIds(String accountId) async {
    try {
      final id = int.parse(accountId);
      final rows = await (_database.select(_database.ownedCards)
            ..where((t) => t.accountId.equals(id)))
          .get();
      return rows.map((row) => row.cardId).toSet();
    } on Exception catch (e) {
      throw CacheException('Échec de la lecture des cartes possédées : $e');
    }
  }

  @override
  Future<void> setCardOwned({
    required String cardId,
    required String accountId,
    required bool owned,
  }) async {
    try {
      final id = int.parse(accountId);
      if (owned) {
        await _database.into(_database.ownedCards).insertOnConflictUpdate(
              OwnedCardsCompanion.insert(cardId: cardId, accountId: id),
            );
      } else {
        await (_database.delete(_database.ownedCards)
              ..where(
                (t) => t.cardId.equals(cardId) & t.accountId.equals(id),
              ))
            .go();
      }
    } on Exception catch (e) {
      throw CacheException('Échec de la mise à jour de la possession : $e');
    }
  }

  CardSetsCompanion _setToCompanion(CardSetModel set) {
    return CardSetsCompanion.insert(
      id: set.id,
      name: set.name,
      totalCardCount: set.totalCardCount,
      seriesId: set.seriesId,
      logoUrl: Value(set.logoUrl),
      officialCardCount: Value(set.officialCardCount),
      packs: Value(set.packs.join(',')),
    );
  }

  CardSetModel _setFromRow(CardSetRow row) {
    return CardSetModel(
      id: row.id,
      name: row.name,
      totalCardCount: row.totalCardCount,
      seriesId: row.seriesId,
      logoUrl: row.logoUrl,
      officialCardCount: row.officialCardCount,
      packs: row.packs.isEmpty ? const [] : row.packs.split(','),
    );
  }

  CardsCompanion _cardToCompanion(CardModel card) {
    return CardsCompanion.insert(
      id: card.id,
      localId: card.localId,
      name: card.name,
      category: card.category.name,
      setId: card.setId,
      setName: card.setName,
      imageUrl: Value(card.imageUrl),
      rarity: Value(card.rarity),
      hp: Value(card.hp),
      types: Value(card.types.join(',')),
      illustrator: Value(card.illustrator),
      packs: Value(card.packs.join(',')),
    );
  }

  CardModel _cardFromRow(CardRow row) {
    return CardModel(
      id: row.id,
      localId: row.localId,
      name: row.name,
      category: CardCategory.values.byName(row.category),
      setId: row.setId,
      setName: row.setName,
      imageUrl: row.imageUrl,
      rarity: row.rarity,
      hp: row.hp,
      types: row.types.isEmpty ? const [] : row.types.split(','),
      illustrator: row.illustrator,
      packs: row.packs.isEmpty ? const [] : row.packs.split(','),
    );
  }
}