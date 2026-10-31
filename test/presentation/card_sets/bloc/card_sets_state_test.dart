import 'package:cartodex/domain/entities/card_set.dart';
import 'package:cartodex/domain/entities/set_progress.dart';
import 'package:cartodex/presentation/card_sets/bloc/card_sets_state.dart';
import 'package:cartodex/presentation/card_sets/bloc/series_tab.dart';
import 'package:flutter_test/flutter_test.dart';

CardSet _set(String id, String seriesId) => CardSet(
      id: id,
      name: id,
      totalCardCount: 0,
      seriesId: seriesId,
    );

SetProgress _progress(
  String setId, {
  required int owned,
  required int total,
}) {
  final group = RarityGroupProgress(
    primaryOwned: owned,
    allAccountsOwned: owned,
    total: total,
  );
  const empty = RarityGroupProgress(
    primaryOwned: 0,
    allAccountsOwned: 0,
    total: 0,
  );
  return SetProgress(setId: setId, base: group, alternative: empty);
}

/// Sets déjà triés du plus récent au plus ancien, comme les renvoie
/// `CardLocalDataSource.getCachedCardSets`. Pas de série D : elle ne
/// doit pas apparaître.
final _sets = [
  _set('E1', 'E'),
  _set('C1', 'C'),
  _set('B2', 'B'),
  _set('B1', 'B'),
  _set('PROMO-B', 'B'),
  _set('A1', 'A'),
  _set('PROMO-A', 'A'),
];

List<String> _keys(List<SeriesTab> tabs) => tabs.map((t) => t.key).toList();

void main() {
  group('CardSetsState.seriesTabs', () {
    test('séries de la plus récente à la plus ancienne, Promo en dernier', () {
      final state = CardSetsState(sets: _sets);
      expect(_keys(state.seriesTabs), ['E', 'C', 'B', 'A', SeriesTab.promoKey]);
    });
  });

  group('CardSetsState.quickTabs', () {
    test('les 3 séries récentes puis Promo', () {
      final state = CardSetsState(sets: _sets, selectedSeriesKey: 'E');
      expect(_keys(state.quickTabs), ['E', 'C', 'B', SeriesTab.promoKey]);
    });

    test('une série ancienne sélectionnée est ajoutée avant Promo', () {
      final state = CardSetsState(sets: _sets, selectedSeriesKey: 'A');
      expect(
        _keys(state.quickTabs),
        ['E', 'C', 'B', 'A', SeriesTab.promoKey],
      );
    });

    test('Promo sélectionné ne change pas la barre', () {
      final state = CardSetsState(
        sets: _sets,
        selectedSeriesKey: SeriesTab.promoKey,
      );
      expect(_keys(state.quickTabs), ['E', 'C', 'B', SeriesTab.promoKey]);
    });
  });

  group('CardSetsState.hasHiddenSeries', () {
    test('vrai au-delà de 3 séries principales', () {
      expect(CardSetsState(sets: _sets).hasHiddenSeries, isTrue);
    });

    test('reste vrai quand la série ancienne est sélectionnée', () {
      final state = CardSetsState(sets: _sets, selectedSeriesKey: 'A');
      expect(state.hasHiddenSeries, isTrue);
    });

    test('faux tant que tout tient dans la barre', () {
      final state = CardSetsState(
        sets: [_set('B1', 'B'), _set('A1', 'A'), _set('PROMO-A', 'A')],
      );
      expect(state.hasHiddenSeries, isFalse);
    });
  });

  group('CardSetsState.setsForSeries', () {
    test('une série principale exclut ses promos', () {
      final state = CardSetsState(sets: _sets);
      expect(state.setsForSeries('B').map((s) => s.id), ['B2', 'B1']);
    });

    test('Promo regroupe les promos de toutes les séries', () {
      final state = CardSetsState(sets: _sets);
      expect(
        state.setsForSeries(SeriesTab.promoKey).map((s) => s.id),
        ['PROMO-B', 'PROMO-A'],
      );
    });

    test('visibleSets suit la série sélectionnée', () {
      final state = CardSetsState(sets: _sets, selectedSeriesKey: 'C');
      expect(state.visibleSets.map((s) => s.id), ['C1']);
    });
  });

  group('CardSetsState.seriesOverviews', () {
    test('cumule la progression des sets de la série', () {
      final state = CardSetsState(
        sets: _sets,
        progressBySetId: {
          'B1': _progress('B1', owned: 10, total: 20),
          'B2': _progress('B2', owned: 30, total: 30),
        },
      );
      final b = state.seriesOverviews.firstWhere((o) => o.tab.key == 'B');
      expect(b.setCount, 2);
      expect(b.primaryOwned, 40);
      expect(b.total, 50);
      expect(b.primaryRatio, closeTo(0.8, 0.0001));
      expect(b.isPrimaryComplete, isFalse);
    });

    test('sans progression connue, pas de pourcentage', () {
      final state = CardSetsState(sets: _sets);
      final e = state.seriesOverviews.first;
      expect(e.tab.key, 'E');
      expect(e.setCount, 1);
      expect(e.hasProgress, isFalse);
    });
  });
}