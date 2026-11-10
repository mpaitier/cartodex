import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/entities/card_set.dart';
import 'package:cartodex/domain/entities/collection_stats.dart';
import 'package:cartodex/domain/entities/progress_count.dart';
import 'package:cartodex/domain/entities/rarity_scope.dart';
import 'package:cartodex/domain/usecases/get_collection_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

/// Quatre familles de sets, du plus récent au plus ancien comme dans
/// le référentiel : une série B, un Deluxe, une série A à deux
/// boosters, et des promos sans booster.
const _b1 = CardSet(
  id: 'B1',
  name: 'Mega Rising',
  totalCardCount: 2,
  seriesId: 'B',
  packs: ['Mega'],
);
const _deluxe = CardSet(
  id: 'A4b',
  name: 'Deluxe Pack: ex',
  totalCardCount: 1,
  seriesId: 'A',
  packs: ['Deluxe'],
);
const _a1 = CardSet(
  id: 'A1',
  name: 'Genetic Apex',
  totalCardCount: 4,
  seriesId: 'A',
  packs: ['Pikachu', 'Mewtwo'],
);
const _promo = CardSet(
  id: 'PROMO-A',
  name: 'Promo-A',
  totalCardCount: 1,
  seriesId: 'PROMO',
);

final _cardsBySetId = {
  'B1': [
    testCard('B1', 1, 'C', packs: ['Mega']),
    testCard('B1', 2, 'AR', packs: ['Mega']),
  ],
  'A4b': [
    testCard('A4b', 1, 'C', packs: ['Deluxe']),
  ],
  'A1': [
    testCard('A1', 1, 'C', packs: ['Pikachu']),
    testCard('A1', 2, 'U', packs: ['Mewtwo']),
    // Commune aux deux boosters : une seule fois dans le total du set.
    testCard('A1', 3, 'C', packs: ['Pikachu', 'Mewtwo']),
    testCard('A1', 4, 'AR', packs: ['Pikachu']),
  ],
  'PROMO-A': [
    testCard('PROMO-A', 1, null),
  ],
};

const _owned = {
  'main': {'A1-1', 'A1-4', 'B1-1'},
  // A1-1 est déjà au principal : seuls A1-2 et PROMO-A-1 comptent en Y.
  'second': {'A1-1', 'A1-2', 'PROMO-A-1'},
};

FakeCardRepository _repository() => FakeCardRepository(
      sets: const [_b1, _deluxe, _a1, _promo],
      cardsBySetId: _cardsBySetId,
      ownedByAccountId: _owned,
    );

Future<CollectionStats> _stats({
  RarityScope scope = RarityScope.all,
  FakeCardRepository? repository,
}) async {
  final result = await GetCollectionStats(repository ?? _repository())(
    GetCollectionStatsParams(
      primaryAccountId: 'main',
      secondaryAccountIds: const ['second'],
      rarityScope: scope,
    ),
  );
  return result.getOrElse(() => throw StateError('échec inattendu'));
}

ProgressCount _count(int owned, int extra, int total) =>
    ProgressCount(owned: owned, secondaryExtra: extra, total: total);

void main() {
  group('GetCollectionStats', () {
    test('progression globale X (+Y) / Z, sans double-comptage', () async {
      final stats = await _stats();
      expect(stats.overall, _count(3, 2, 8));
    });

    test(
        'séries lettrées dans l’ordre du référentiel, '
        'puis Deluxe, puis Promo', () async {
      final stats = await _stats();
      expect(
        [for (final series in stats.seriesStats) series.seriesKey],
        ['B', 'A', 'DELUXE', 'PROMO'],
      );
      expect(
        [for (final series in stats.seriesStats) series.label],
        ['B', 'A', 'Deluxe', 'Promo'],
      );
      expect(
        [for (final series in stats.seriesStats) series.progress],
        [_count(1, 0, 2), _count(2, 1, 4), _count(0, 0, 1), _count(0, 1, 1)],
      );
    });

    test('boosters : promos exclues, Deluxe inclus, union par set', () async {
      final stats = await _stats();
      expect(
        [for (final set in stats.setBoosterProgress) set.set.id],
        ['B1', 'A4b', 'A1'],
      );

      final a1 = stats.setBoosterProgress.last;
      expect(a1.seriesKey, 'A');
      expect(a1.progress, _count(2, 1, 4));
      expect(
        [for (final booster in a1.boosters) booster.packName],
        ['Pikachu', 'Mewtwo'],
      );
      expect(
        [for (final booster in a1.boosters) booster.progress],
        [_count(2, 0, 3), _count(0, 1, 2)],
      );
    });

    test('sans probabilités de tirage, pas d’espérance calculée', () async {
      final stats = await _stats();
      final boosters = [
        for (final set in stats.setBoosterProgress) ...set.boosters,
      ];
      expect(
        boosters.map((booster) => booster.expectedNewCards),
        everyElement(isNull),
      );
    });

    test('périmètre losange : seules les cartes de base comptent', () async {
      final stats = await _stats(scope: RarityScope.diamond);
      // A1-1, A1-2, A1-3, B1-1, A4b-1 ; A1-4 et B1-2 (AR) et la promo
      // sans rareté en sont exclues.
      expect(stats.overall, _count(2, 1, 5));
    });

    test('périmètre étoile : seules les cartes alternatives comptent',
        () async {
      final stats = await _stats(scope: RarityScope.star);
      // A1-4, B1-2 et la promo sans rareté connue.
      expect(stats.overall, _count(1, 1, 3));
    });

    test('un échec de lecture de la possession est remonté', () async {
      final repository = _repository()..failingAccountId = 'second';
      final result = await GetCollectionStats(repository)(
        const GetCollectionStatsParams(
          primaryAccountId: 'main',
          secondaryAccountIds: ['second'],
        ),
      );
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<CacheFailure>(),
      );
    });
  });
}
