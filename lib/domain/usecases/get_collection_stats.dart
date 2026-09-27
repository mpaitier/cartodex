import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../entities/card_set.dart';
import '../entities/collection_stats.dart';
import '../entities/pokemon_card.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Clé de regroupement des sets promotionnels dans
/// [CollectionStats.seriesStats] — même principe que
/// `CardSetsState.seriesTabs` côté présentation (un "Promo" combiné,
/// affiché en dernier), mais recalculé ici pour rester indépendant
/// de la couche présentation.
const _promoSeriesKey = 'PROMO';

/// Calcule les statistiques de complétion d'un compte : taux global,
/// par série, et par booster (voir [CollectionStats]).
///
/// Combine trois appels déjà exposés par [CardRepository]
/// (`getCardSets`, `getCardsBySet` pour chaque set, `getOwnedCardIds`)
/// plutôt que d'ajouter une méthode dédiée au repository : ce calcul
/// est une règle métier, pas un accès aux données, et a donc sa place
/// dans un use case plutôt que dans le repository ou dans un Bloc.
class GetCollectionStats
    implements UseCase<CollectionStats, GetCollectionStatsParams> {
  const GetCollectionStats(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, CollectionStats>> call(
    GetCollectionStatsParams params,
  ) async {
    final setsResult = await _repository.getCardSets();
    final ownedResult = await _repository.getOwnedCardIds(params.accountId);

    final failure = setsResult.fold((f) => f, (_) => null) ??
        ownedResult.fold((f) => f, (_) => null);
    if (failure != null) return Left(failure);

    final sets = setsResult.getOrElse(() => const []);
    final ownedIds = ownedResult.getOrElse(() => const <String>{});

    final cardsBySetId = <String, List<PokemonCard>>{};
    for (final set in sets) {
      final cardsResult = await _repository.getCardsBySet(set.id);
      final cardsFailure = cardsResult.fold((f) => f, (_) => null);
      if (cardsFailure != null) return Left(cardsFailure);
      cardsBySetId[set.id] = cardsResult.getOrElse(() => const []);
    }

    return Right(
      _buildStats(sets: sets, cardsBySetId: cardsBySetId, ownedIds: ownedIds),
    );
  }

  CollectionStats _buildStats({
    required List<CardSet> sets,
    required Map<String, List<PokemonCard>> cardsBySetId,
    required Set<String> ownedIds,
  }) {
    var totalOwned = 0;
    var totalCards = 0;
    final seriesAccumulators = <String, _SeriesAccumulator>{};
    final boosterStats = <BoosterStats>[];

    for (final set in sets) {
      final cards = cardsBySetId[set.id] ?? const [];
      final ownedInSet = cards.where((c) => ownedIds.contains(c.id)).length;
      totalOwned += ownedInSet;
      totalCards += cards.length;

      final seriesKey = set.isPromo ? _promoSeriesKey : set.seriesId;
      final accumulator = seriesAccumulators.putIfAbsent(
        seriesKey,
        () => _SeriesAccumulator(label: set.isPromo ? 'Promo' : set.seriesId),
      );
      accumulator.owned += ownedInSet;
      accumulator.total += cards.length;

      for (final pack in set.packs) {
        final packCards = cards.where((c) => c.packs.contains(pack)).toList();
        if (packCards.isEmpty) continue;
        final packOwned =
            packCards.where((c) => ownedIds.contains(c.id)).length;
        boosterStats.add(
          BoosterStats(
            setId: set.id,
            setName: set.name,
            packName: pack,
            owned: packOwned,
            total: packCards.length,
          ),
        );
      }
    }

    // Séries lettrées dans leur ordre de rencontre (déjà du plus
    // récent au plus ancien, comme `sets`), puis "Promo" en dernier
    // s'il y en a un — même convention que `CardSetsState.seriesTabs`.
    final orderedKeys = seriesAccumulators.keys
        .where((key) => key != _promoSeriesKey)
        .toList();
    if (seriesAccumulators.containsKey(_promoSeriesKey)) {
      orderedKeys.add(_promoSeriesKey);
    }
    final seriesStats = orderedKeys.map((key) {
      final accumulator = seriesAccumulators[key]!;
      return SeriesStats(
        seriesKey: key,
        label: accumulator.label,
        owned: accumulator.owned,
        total: accumulator.total,
      );
    }).toList();

    return CollectionStats(
      totalOwned: totalOwned,
      totalCards: totalCards,
      seriesStats: seriesStats,
      boosterStats: boosterStats,
    );
  }
}

/// Accumulateur mutable interne, le temps de regrouper les sets par
/// série avant de produire les [SeriesStats] finaux (immuables).
class _SeriesAccumulator {
  _SeriesAccumulator({required this.label});

  final String label;
  int owned = 0;
  int total = 0;
}

/// Paramètre attendu par [GetCollectionStats].
class GetCollectionStatsParams extends Equatable {
  const GetCollectionStatsParams({required this.accountId});

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}