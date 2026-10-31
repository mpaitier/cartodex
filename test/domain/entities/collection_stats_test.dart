import 'package:cartodex/domain/entities/collection_stats.dart';
import 'package:cartodex/domain/entities/progress_count.dart';
import 'package:flutter_test/flutter_test.dart';

ProgressCount _count(int owned, int total) =>
    ProgressCount(owned: owned, secondaryExtra: 0, total: total);

SetBoosterProgress _set(String id, String seriesKey, int owned, int total) =>
    SetBoosterProgress(
      setId: id,
      setName: id,
      seriesKey: seriesKey,
      progress: _count(owned, total),
      boosters: [
        BoosterStats(
          setId: id,
          setName: id,
          packName: id,
          progress: _count(owned, total),
        ),
      ],
    );

SeriesStats _series(String key, String label) =>
    SeriesStats(seriesKey: key, label: label, progress: ProgressCount.zero);

CollectionStats _stats() => CollectionStats(
      overall: ProgressCount.zero,
      seriesStats: [
        _series('B', 'B'),
        _series('A', 'A'),
        _series('DELUXE', 'Deluxe'),
        _series('PROMO', 'Promo'),
      ],
      setBoosterProgress: [
        _set('B1', 'B', 2, 10),
        _set('A1', 'A', 5, 10),
        _set('A2', 'A', 1, 10),
        _set('A3', 'A', 10, 10),
        _set('A4a', 'DELUXE', 3, 10),
      ],
    );

List<String> _ids(List<SetBoosterProgress> sets) =>
    sets.map((s) => s.setId).toList();

void main() {
  group('CollectionStats.priorityBoosterProgressFor', () {
    test('sans série, garde tous les sets incomplets, du moins avancé '
        'au plus avancé', () {
      expect(
        _ids(_stats().priorityBoosterProgressFor(null)),
        ['A2', 'B1', 'A4a', 'A1'],
      );
    });

    test('avec une série, ne garde que les sets de cette série', () {
      expect(_ids(_stats().priorityBoosterProgressFor('A')), ['A2', 'A1']);
      expect(_ids(_stats().priorityBoosterProgressFor('B')), ['B1']);
      expect(_ids(_stats().priorityBoosterProgressFor('DELUXE')), ['A4a']);
    });

    test('une série sans booster donne une liste vide', () {
      expect(_stats().priorityBoosterProgressFor('PROMO'), isEmpty);
    });
  });

  group('CollectionStats.boosterSeries', () {
    test('garde l’ordre de seriesStats et écarte les séries sans booster',
        () {
      expect(
        _stats().boosterSeries.map((s) => s.seriesKey).toList(),
        ['B', 'A', 'DELUXE'],
      );
    });
  });
}
