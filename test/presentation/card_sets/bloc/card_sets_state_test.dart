import 'package:cartodex/domain/entities/card_set.dart';
import 'package:cartodex/domain/entities/progress_count.dart';
import 'package:cartodex/domain/entities/rarity_scope.dart';
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

/// (cartes du compte principal, total) d'un `SeriesOverview`.
typedef SeriesOverviewCounts = (int, int);

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
      final b = state
          .seriesOverviews(RarityScope.all)
          .firstWhere((o) => o.tab.key == 'B');
      expect(b.setCount, 2);
      expect(b.primaryOwned, 40);
      expect(b.total, 50);
      expect(b.primaryRatio, closeTo(0.8, 0.0001));
      expect(b.isPrimaryComplete, isFalse);
    });

    test('suit le périmètre de raretés global', () {
      const progress = SetProgress(
        setId: 'C1',
        base: RarityGroupProgress(
          primaryOwned: 8,
          allAccountsOwned: 8,
          total: 10,
        ),
        alternative: RarityGroupProgress(
          primaryOwned: 1,
          allAccountsOwned: 1,
          total: 5,
        ),
      );
      final state = CardSetsState(
        sets: _sets,
        progressBySetId: const {'C1': progress},
      );
      SeriesOverviewCounts c(RarityScope scope) {
        final o =
            state.seriesOverviews(scope).firstWhere((o) => o.tab.key == 'C');
        return (o.primaryOwned, o.total);
      }

      expect(c(RarityScope.all), (9, 15));
      expect(c(RarityScope.diamond), (8, 10));
      expect(c(RarityScope.star), (1, 5));
    });

    test('sans progression connue, pas de pourcentage', () {
      final state = CardSetsState(sets: _sets);
      final e = state.seriesOverviews(RarityScope.all).first;
      expect(e.tab.key, 'E');
      expect(e.setCount, 1);
      expect(e.hasProgress, isFalse);
    });
  });

  group('CardSetsState.seriesProgressFor', () {
    // Deux sets de la série A : losanges et étoiles séparés, avec des
    // cartes que seuls les secondaires possèdent.
    final sets = [_set('A2', 'A'), _set('A1', 'A'), _set('B1', 'B')];
    const progress = {
      'A2': SetProgress(
        setId: 'A2',
        base: RarityGroupProgress(
          primaryOwned: 10,
          allAccountsOwned: 12,
          total: 20,
        ),
        alternative: RarityGroupProgress(
          primaryOwned: 1,
          allAccountsOwned: 1,
          total: 5,
        ),
      ),
      'A1': SetProgress(
        setId: 'A1',
        base: RarityGroupProgress(
          primaryOwned: 30,
          allAccountsOwned: 30,
          total: 30,
        ),
        alternative: RarityGroupProgress(
          primaryOwned: 0,
          allAccountsOwned: 3,
          total: 10,
        ),
      ),
    };

    test('Σ additionne losanges et étoiles de tous les sets de la série',
        () {
      final state = CardSetsState(sets: sets, progressBySetId: progress);
      expect(
        state.seriesProgressFor('A', RarityScope.all),
        const ProgressCount(owned: 41, secondaryExtra: 5, total: 65),
      );
    });

    test('losange et étoile ne gardent que leur groupe', () {
      final state = CardSetsState(sets: sets, progressBySetId: progress);
      expect(
        state.seriesProgressFor('A', RarityScope.diamond),
        const ProgressCount(owned: 40, secondaryExtra: 2, total: 50),
      );
      expect(
        state.seriesProgressFor('A', RarityScope.star),
        const ProgressCount(owned: 1, secondaryExtra: 3, total: 15),
      );
    });

    test('sans progression connue pour la série, rien à afficher', () {
      final state = CardSetsState(sets: sets, progressBySetId: progress);
      expect(state.seriesProgressFor('B', RarityScope.all), isNull);
    });
  });
}
