import 'package:cartodex/domain/entities/collection_stats.dart';
import 'package:cartodex/domain/entities/progress_count.dart';
import 'package:flutter_test/flutter_test.dart';

ProgressCount _count(int owned, int total) =>
    ProgressCount(owned: owned, secondaryExtra: 0, total: total);

BoosterStats _booster(
  String setId,
  String packName,
  int owned,
  int total, {
  double? expected,
}) =>
    BoosterStats(
      setId: setId,
      setName: setId,
      packName: packName,
      progress: _count(owned, total),
      expectedNewCards: expected,
    );

SetBoosterProgress _set(
  String id,
  String seriesKey,
  int owned,
  int total, {
  double? expected,
}) =>
    SetBoosterProgress(
      setId: id,
      setName: id,
      seriesKey: seriesKey,
      progress: _count(owned, total),
      boosters: [_booster(id, id, owned, total, expected: expected)],
    );

SeriesStats _series(String key, String label) =>
    SeriesStats(seriesKey: key, label: label, progress: ProgressCount.zero);

CollectionStats _stats(List<SetBoosterProgress> sets) => CollectionStats(
      overall: ProgressCount.zero,
      seriesStats: [
        _series('B', 'B'),
        _series('A', 'A'),
        _series('DELUXE', 'Deluxe'),
        _series('PROMO', 'Promo'),
      ],
      setBoosterProgress: sets,
    );

/// Sets sans probabilités connues : seul l'ancien critère (la
/// progression) peut les départager.
CollectionStats _statsWithoutRates() => _stats([
      _set('B1', 'B', 2, 10),
      _set('A1', 'A', 5, 10),
      _set('A2', 'A', 1, 10),
      _set('A3', 'A', 10, 10),
      _set('A4a', 'DELUXE', 3, 10),
    ]);

List<String> _ids(List<SetBoosterProgress> sets) =>
    sets.map((s) => s.setId).toList();

void main() {
  group('CollectionStats.priorityBoosterProgressFor', () {
    test('classe les sets par espérance de cartes manquantes, la plus '
        'forte d’abord', () {
      final stats = _stats([
        _set('A1', 'A', 9, 10, expected: 0.2),
        _set('A2', 'A', 1, 10, expected: 0.1),
        _set('B1', 'B', 5, 10, expected: 1.4),
      ]);
      expect(_ids(stats.priorityBoosterProgressFor(null)), ['B1', 'A1', 'A2']);
    });

    test('un set sans probabilités passe après les autres', () {
      final stats = _stats([
        _set('A1', 'A', 0, 10),
        _set('A2', 'A', 9, 10, expected: 0.05),
      ]);
      expect(_ids(stats.priorityBoosterProgressFor(null)), ['A2', 'A1']);
    });

    test('sans probabilités, retombe sur la progression, du moins avancé '
        'au plus avancé, sets complets exclus', () {
      expect(
        _ids(_statsWithoutRates().priorityBoosterProgressFor(null)),
        ['A2', 'B1', 'A4a', 'A1'],
      );
    });

    test('un set à plusieurs boosters se classe sur son meilleur booster, '
        'et ses boosters sont triés de la même façon', () {
      final multi = SetBoosterProgress(
        setId: 'A1',
        setName: 'A1',
        seriesKey: 'A',
        progress: _count(5, 20),
        boosters: [
          _booster('A1', 'Mewtwo', 2, 10, expected: 0.3),
          _booster('A1', 'Pikachu', 3, 10, expected: 0.9),
          _booster('A1', 'Charizard', 1, 10),
        ],
      );
      final stats = _stats([
        _set('A2', 'A', 0, 10, expected: 0.6),
        multi,
      ]);
      final result = stats.priorityBoosterProgressFor(null);
      expect(_ids(result), ['A1', 'A2']);
      expect(
        result.first.boosters.map((b) => b.packName).toList(),
        ['Pikachu', 'Mewtwo', 'Charizard'],
      );
    });

    test('avec une série, ne garde que les sets de cette série', () {
      final stats = _statsWithoutRates();
      expect(_ids(stats.priorityBoosterProgressFor('A')), ['A2', 'A1']);
      expect(_ids(stats.priorityBoosterProgressFor('B')), ['B1']);
      expect(_ids(stats.priorityBoosterProgressFor('DELUXE')), ['A4a']);
    });

    test('une série sans booster donne une liste vide', () {
      expect(_statsWithoutRates().priorityBoosterProgressFor('PROMO'), isEmpty);
    });
  });

  group('SetBoosterProgress.expectedNewCards', () {
    test('vaut l’espérance du meilleur booster', () {
      final set = SetBoosterProgress(
        setId: 'A1',
        setName: 'A1',
        seriesKey: 'A',
        progress: _count(0, 10),
        boosters: [
          _booster('A1', 'Mewtwo', 0, 10, expected: 0.4),
          _booster('A1', 'Pikachu', 0, 10, expected: 1.1),
        ],
      );
      expect(set.expectedNewCards, 1.1);
    });

    test('est nul quand aucun booster n’a de probabilités', () {
      expect(_set('A1', 'A', 0, 10).expectedNewCards, isNull);
    });
  });

  group('CollectionStats.boosterSeries', () {
    test('garde l’ordre de seriesStats et écarte les séries sans booster',
        () {
      expect(
        _statsWithoutRates().boosterSeries.map((s) => s.seriesKey).toList(),
        ['B', 'A', 'DELUXE'],
      );
    });
  });
}
