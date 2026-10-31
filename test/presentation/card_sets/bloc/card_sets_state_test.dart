import 'package:cartodex/domain/entities/card_set.dart';
import 'package:cartodex/domain/entities/set_progress.dart';
import 'package:cartodex/presentation/card_sets/bloc/card_sets_state.dart';
import 'package:cartodex/presentation/card_sets/bloc/series_tab.dart';
import 'package:flutter_test/flutter_test.dart';

CardSet _set(String id, String seriesId, {String? name}) => CardSet(
      id: id,
      name: name ?? id,
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
  _set('B4b', 'B', name: 'Deluxe Pack: Mega'),
  _set('B2', 'B'),
  _set('B1', 'B'),
  _set('PROMO-B', 'B'),
  _set('A4b', 'A', name: 'Deluxe Pack: ex'),
  _set('A1', 'A'),
  _set('PROMO-A', 'A'),
];

const _deluxe = SeriesTab.deluxeKey;
const _promo = SeriesTab.promoKey;

List<String> _keys(List<SeriesTab> tabs) => tabs.map((t) => t.key).toList();

void main() {
  group('CardSetsState.seriesTabs', () {
    test('séries récentes en premier, puis Deluxe, puis Promo', () {
      final state = CardSetsState(sets: _sets);
      expect(_keys(state.seriesTabs), ['E', 'C', 'B', 'A', _deluxe, _promo]);
    });

    test('pas d\'onglet Deluxe sans booster Deluxe', () {
      final state = CardSetsState(
        sets: [_set('A1', 'A'), _set('PROMO-A', 'A')],
      );
      expect(_keys(state.seriesTabs), ['A', _promo]);
    });
  });

  group('CardSetsState.quickTabs', () {
    test('les 3 séries récentes puis les sections spéciales', () {
      final state = CardSetsState(sets: _sets, selectedSeriesKey: 'E');
      expect(_keys(state.quickTabs), ['E', 'C', 'B', _deluxe, _promo]);
    });

    test('une série ancienne sélectionnée est ajoutée avant Deluxe', () {
      final state = CardSetsState(sets: _sets, selectedSeriesKey: 'A');
      expect(_keys(state.quickTabs), ['E', 'C', 'B', 'A', _deluxe, _promo]);
    });

    test('Deluxe sélectionné ne change pas la barre', () {
      final state = CardSetsState(sets: _sets, selectedSeriesKey: _deluxe);
      expect(_keys(state.quickTabs), ['E', 'C', 'B', _deluxe, _promo]);
    });
  });

  group('CardSetsState.hasHiddenSeries', () {
    test('vrai au-delà de 3 séries lettrées', () {
      expect(CardSetsState(sets: _sets).hasHiddenSeries, isTrue);
    });

    test('reste vrai quand la série ancienne est sélectionnée', () {
      final state = CardSetsState(sets: _sets, selectedSeriesKey: 'A');
      expect(state.hasHiddenSeries, isTrue);
    });

    test('Deluxe et Promo ne comptent pas comme séries cachées', () {
      final state = CardSetsState(
        sets: [
          _set('C1', 'C'),
          _set('B1', 'B'),
          _set('A4b', 'A', name: 'Deluxe Pack: ex'),
          _set('A1', 'A'),
          _set('PROMO-A', 'A'),
        ],
      );
      expect(state.hasHiddenSeries, isFalse);
    });
  });

  group('CardSetsState.setsForSeries', () {
    test('une série lettrée exclut ses promos et ses Deluxe', () {
      final state = CardSetsState(sets: _sets);
      expect(state.setsForSeries('B').map((s) => s.id), ['B2', 'B1']);
      expect(state.setsForSeries('A').map((s) => s.id), ['A1']);
    });

    test('Deluxe regroupe les boosters Deluxe de toutes les séries', () {
      final state = CardSetsState(sets: _sets);
      expect(state.setsForSeries(_deluxe).map((s) => s.id), ['B4b', 'A4b']);
    });

    test('Promo regroupe les promos de toutes les séries', () {
      final state = CardSetsState(sets: _sets);
      expect(
        state.setsForSeries(_promo).map((s) => s.id),
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
          // B4b est Deluxe : il ne doit pas compter dans B.
          'B4b': _progress('B4b', owned: 0, total: 100),
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