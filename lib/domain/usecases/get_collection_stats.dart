import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../entities/card_set.dart';
import '../entities/collection_stats.dart';
import '../entities/pokemon_card.dart';
import '../entities/progress_count.dart';
import '../entities/rarity_scope.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Clé de regroupement des sets promotionnels dans
/// [CollectionStats.seriesStats] — même principe que
/// `CardSetsState.seriesTabs` côté présentation (un "Promo" combiné,
/// affiché en dernier), mais recalculé ici pour rester indépendant
/// de la couche présentation.
const _promoSeriesKey = 'PROMO';

/// Calcule les statistiques de complétion : taux global, par série,
/// et progression des boosters par set (voir [CollectionStats]).
///
/// Chaque progression est un [ProgressCount] "X (+Y) / Z" :
/// - X : cartes possédées par le compte principal ;
/// - Y : cartes possédées par au moins un compte secondaire mais pas
///   par le principal (union des secondaires, sans doublon, privée
///   des cartes du principal) ;
/// - Z : cartes existantes dans le périmètre de raretés demandé
///   ([GetCollectionStatsParams.rarityScope]).
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
    final primaryResult =
        await _repository.getOwnedCardIds(params.primaryAccountId);

    final failure = setsResult.fold((f) => f, (_) => null) ??
        primaryResult.fold((f) => f, (_) => null);
    if (failure != null) return Left(failure);

    final sets = setsResult.getOrElse(() => const []);
    final primaryIds = primaryResult.getOrElse(() => const <String>{});

    // Union des cartes de tous les secondaires.
    final secondaryIds = <String>{};
    for (final accountId in params.secondaryAccountIds) {
      final ownedResult = await _repository.getOwnedCardIds(accountId);
      final ownedFailure = ownedResult.fold((f) => f, (_) => null);
      if (ownedFailure != null) return Left(ownedFailure);
      secondaryIds.addAll(ownedResult.getOrElse(() => const <String>{}));
    }
    // Ne garde que ce que le principal n'a pas déjà : pas de
    // double-comptage entre X et Y.
    final secondaryOnlyIds = secondaryIds.difference(primaryIds);

    final cardsBySetId = <String, List<PokemonCard>>{};
    for (final set in sets) {
      final cardsResult = await _repository.getCardsBySet(set.id);
      final cardsFailure = cardsResult.fold((f) => f, (_) => null);
      if (cardsFailure != null) return Left(cardsFailure);
      cardsBySetId[set.id] = cardsResult
          .getOrElse(() => const <PokemonCard>[])
          .where((card) => params.rarityScope.includes(card.rarity))
          .toList();
    }

    return Right(
      _buildStats(
        sets: sets,
        cardsBySetId: cardsBySetId,
        primaryIds: primaryIds,
        secondaryOnlyIds: secondaryOnlyIds,
      ),
    );
  }

  /// Compte, parmi [cardIds], ce que possède le principal (X), ce
  /// que les secondaires ajoutent (Y), et le total (Z).
  ProgressCount _countFor(
    Iterable<String> cardIds, {
    required Set<String> primaryIds,
    required Set<String> secondaryOnlyIds,
  }) {
    var owned = 0;
    var secondaryExtra = 0;
    var total = 0;
    for (final id in cardIds) {
      total++;
      if (primaryIds.contains(id)) {
        owned++;
      } else if (secondaryOnlyIds.contains(id)) {
        secondaryExtra++;
      }
    }
    return ProgressCount(
      owned: owned,
      secondaryExtra: secondaryExtra,
      total: total,
    );
  }

  CollectionStats _buildStats({
    required List<CardSet> sets,
    required Map<String, List<PokemonCard>> cardsBySetId,
    required Set<String> primaryIds,
    required Set<String> secondaryOnlyIds,
  }) {
    var overall = ProgressCount.zero;
    final seriesAccumulators = <String, _SeriesAccumulator>{};
    final setBoosterProgress = <SetBoosterProgress>[];

    for (final set in sets) {
      final cards = cardsBySetId[set.id] ?? const <PokemonCard>[];
      final setCount = _countFor(
        cards.map((c) => c.id),
        primaryIds: primaryIds,
        secondaryOnlyIds: secondaryOnlyIds,
      );
      overall += setCount;

      final seriesKey = set.isPromo ? _promoSeriesKey : set.seriesId;
      final accumulator = seriesAccumulators.putIfAbsent(
        seriesKey,
        () => _SeriesAccumulator(label: set.isPromo ? 'Promo' : set.seriesId),
      );
      accumulator.progress += setCount;

      // Progression par booster : on ignore les sets promotionnels
      // (jamais recommandé d'ouvrir un booster promo) et les sets
      // sans booster connu — rien à recommander dans ce cas.
      if (set.isPromo || set.packs.isEmpty) continue;

      final cardIdsByPack = <String, Set<String>>{};
      for (final pack in set.packs) {
        final ids =
            cards.where((c) => c.packs.contains(pack)).map((c) => c.id).toSet();
        if (ids.isNotEmpty) cardIdsByPack[pack] = ids;
      }
      if (cardIdsByPack.isEmpty) continue;

      // Union des boosters, pas somme : une carte commune à
      // plusieurs boosters du même set ne doit compter qu'une fois
      // dans la progression globale du set.
      final unionIds = <String>{};
      for (final ids in cardIdsByPack.values) {
        unionIds.addAll(ids);
      }

      final boosters = cardIdsByPack.entries
          .map(
            (entry) => BoosterStats(
              setId: set.id,
              setName: set.name,
              packName: entry.key,
              progress: _countFor(
                entry.value,
                primaryIds: primaryIds,
                secondaryOnlyIds: secondaryOnlyIds,
              ),
            ),
          )
          .toList();

      setBoosterProgress.add(
        SetBoosterProgress(
          setId: set.id,
          setName: set.name,
          progress: _countFor(
            unionIds,
            primaryIds: primaryIds,
            secondaryOnlyIds: secondaryOnlyIds,
          ),
          boosters: boosters,
        ),
      );
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
        progress: accumulator.progress,
      );
    }).toList();

    return CollectionStats(
      overall: overall,
      seriesStats: seriesStats,
      setBoosterProgress: setBoosterProgress,
    );
  }
}

/// Accumulateur mutable interne, le temps de regrouper les sets par
/// série avant de produire les [SeriesStats] finaux (immuables).
class _SeriesAccumulator {
  _SeriesAccumulator({required this.label});

  final String label;
  ProgressCount progress = ProgressCount.zero;
}

/// Paramètres attendus par [GetCollectionStats].
class GetCollectionStatsParams extends Equatable {
  const GetCollectionStatsParams({
    required this.primaryAccountId,
    this.secondaryAccountIds = const [],
    this.rarityScope = RarityScope.all,
  });

  /// Compte principal : sa possession donne X.
  final String primaryAccountId;

  /// Comptes secondaires : leur union (privée du principal) donne Y.
  final List<String> secondaryAccountIds;

  /// Périmètre de raretés pris en compte (rond / losange / étoile).
  final RarityScope rarityScope;

  @override
  List<Object?> get props =>
      [primaryAccountId, secondaryAccountIds, rarityScope];
}