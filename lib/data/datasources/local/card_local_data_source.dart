import 'package:drift/drift.dart';

import '../../../core/error/exceptions.dart';
import '../../../domain/entities/card_category.dart';
import '../../../domain/entities/pack_variant_pull_rates.dart';
import '../../../domain/entities/slot_pull_rates.dart';
import '../../models/card_model.dart';
import '../../models/card_set_model.dart';
import '../../models/set_pull_rates_model.dart';
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

  /// Remplace toutes les probabilités de tirage par [pullRates]. Pas
  /// de mise à jour set par set : la source publie un seul fichier,
  /// qui fait foi dans son ensemble.
  Future<void> cachePullRates(List<SetPullRatesModel> pullRates);

  /// Probabilités de tirage en cache, un élément par set. Liste vide
  /// tant qu'aucune synchronisation ne les a récupérées.
  Future<List<SetPullRatesModel>> getCachedPullRates();

  /// Cartes possédées par le compte [accountId] uniquement : la
  /// possession n'est plus globale (voir [OwnedCards][tables/owned_cards_table.dart]).
  Future<Set<String>> getOwnedCardIds(String accountId);

  Future<void> setCardOwned({
    required String cardId,
    required String accountId,
    required bool owned,
  });

  /// Marque toutes les cartes de [cardIds] comme possédées par
  /// [accountId], en une seule opération. N'enlève jamais rien —
  /// utilisé par le bouton "+" du détail d'un set et par la
  /// synchronisation cloud.
  Future<void> addOwnedCards({
    required String accountId,
    required Set<String> cardIds,
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
  Future<void> cachePullRates(List<SetPullRatesModel> pullRates) async {
    try {
      await _database.batch((batch) {
        batch.deleteWhere(_database.pullRates, (_) => const Constant(true));
        batch.insertAll(
          _database.pullRates,
          [for (final set in pullRates) ..._pullRatesToCompanions(set)],
        );
      });
    } on Exception catch (e) {
      throw CacheException(
        'Échec de la mise en cache des probabilités de tirage : $e',
      );
    }
  }

  @override
  Future<List<SetPullRatesModel>> getCachedPullRates() async {
    try {
      final rows = await _database.select(_database.pullRates).get();
      return _pullRatesFromRows(rows);
    } on Exception catch (e) {
      throw CacheException(
        'Échec de la lecture des probabilités de tirage en cache : $e',
      );
    }
  }

  @override
  Future<Set<String>> getOwnedCardIds(String accountId) async {
    try {
      final rows = await (_database.select(_database.ownedCards)
            ..where((t) => t.accountId.equals(accountId)))
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
      if (owned) {
        await _database.into(_database.ownedCards).insertOnConflictUpdate(
              OwnedCardsCompanion.insert(cardId: cardId, accountId: accountId),
            );
      } else {
        await (_database.delete(_database.ownedCards)
              ..where(
                (t) =>
                    t.cardId.equals(cardId) & t.accountId.equals(accountId),
              ))
            .go();
      }
    } on Exception catch (e) {
      throw CacheException('Échec de la mise à jour de la possession : $e');
    }
  }

  @override
  Future<void> addOwnedCards({
    required String accountId,
    required Set<String> cardIds,
  }) async {
    if (cardIds.isEmpty) return;
    try {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.ownedCards,
          [
            for (final cardId in cardIds)
              OwnedCardsCompanion.insert(cardId: cardId, accountId: accountId),
          ],
        );
      });
    } on Exception catch (e) {
      throw CacheException(
        'Échec de l\'ajout groupé de cartes possédées : $e',
      );
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

  /// Une ligne par (variante, emplacement, rareté) : voir
  /// [PullRates][tables/pull_rates_table.dart].
  Iterable<PullRatesCompanion> _pullRatesToCompanions(
    SetPullRatesModel set,
  ) sync* {
    for (final variant in set.variants) {
      for (var slot = 0; slot < variant.slots.length; slot++) {
        final rates = variant.slots[slot].rateByRarity;
        for (final entry in rates.entries) {
          yield PullRatesCompanion.insert(
            setId: set.setId,
            packVariant: variant.name,
            appearanceRate: variant.appearanceRate,
            slot: slot,
            rarity: entry.key,
            rate: entry.value,
          );
        }
      }
    }
  }

  /// Regroupe les lignes à plat de [PullRates] par set, puis par
  /// variante, puis par emplacement. L'ordre des variantes suit celui
  /// de la première ligne lue de chacune ; les emplacements sont
  /// remis dans l'ordre de leur rang.
  List<SetPullRatesModel> _pullRatesFromRows(List<PullRateRow> rows) {
    final bySet = <String, Map<String, _VariantRows>>{};
    for (final row in rows) {
      final variants = bySet.putIfAbsent(row.setId, () => {});
      final variant = variants.putIfAbsent(
        row.packVariant,
        () => _VariantRows(row.appearanceRate),
      );
      variant.ratesBySlot.putIfAbsent(row.slot, () => {})[row.rarity] =
          row.rate;
    }
    return [
      for (final setEntry in bySet.entries)
        SetPullRatesModel(
          setId: setEntry.key,
          variants: [
            for (final variantEntry in setEntry.value.entries)
              PackVariantPullRates(
                name: variantEntry.key,
                appearanceRate: variantEntry.value.appearanceRate,
                slots: variantEntry.value.sortedSlots,
              ),
          ],
        ),
    ];
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

/// Accumulateur interne de [CardLocalDataSourceImpl._pullRatesFromRows] :
/// les lignes d'une variante de booster, le temps de les regrouper par
/// emplacement.
class _VariantRows {
  _VariantRows(this.appearanceRate);

  final double appearanceRate;
  final Map<int, Map<String, double>> ratesBySlot = {};

  List<SlotPullRates> get sortedSlots {
    final slots = ratesBySlot.keys.toList()..sort();
    return [for (final slot in slots) SlotPullRates(ratesBySlot[slot]!)];
  }
}
