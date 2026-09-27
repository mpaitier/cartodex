import 'package:equatable/equatable.dart';

/// Statistiques de complétion d'un compte, calculées par
/// `GetCollectionStats` : taux global, détail par série, et
/// progression des boosters par set (pour savoir lesquels ouvrir en
/// priorité — voir [CollectionStats.priorityBoosterProgress]).
class CollectionStats extends Equatable {
  const CollectionStats({
    required this.totalOwned,
    required this.totalCards,
    required this.seriesStats,
    required this.setBoosterProgress,
  });

  /// Cartes possédées, tous sets confondus.
  final int totalOwned;

  /// Cartes existantes, tous sets confondus.
  final int totalCards;

  /// Une entrée par série (regroupement identique à
  /// `SeriesFilterBar` : une série lettrée par entrée, plus un
  /// "Promo" combiné en dernier).
  final List<SeriesStats> seriesStats;

  /// Progression des boosters, par set — hors sets promotionnels et
  /// hors sets sans booster connu (voir `GetCollectionStats`). Sert
  /// de base à [priorityBoosterProgress].
  final List<SetBoosterProgress> setBoosterProgress;

  double get completionRatio => totalCards == 0 ? 0 : totalOwned / totalCards;

  /// [setBoosterProgress] restreint aux sets pas encore complets côté
  /// boosters, du moins avancé au plus avancé — les meilleurs
  /// candidats à ouvrir en priorité : plus un set est loin d'être
  /// complet, plus une carte tirée dans l'un de ses boosters a de
  /// chances d'être encore manquante. À l'intérieur d'un set à
  /// plusieurs boosters, ceux-ci sont eux aussi triés du moins avancé
  /// au plus avancé, pour indiquer lequel ouvrir en premier au sein
  /// du set.
  List<SetBoosterProgress> get priorityBoosterProgress {
    final incomplete = setBoosterProgress
        .where((set) => !set.isComplete)
        .map((set) {
          if (!set.hasMultipleBoosters) return set;
          final sortedBoosters = List<BoosterStats>.from(set.boosters)
            ..sort((a, b) => a.completionRatio.compareTo(b.completionRatio));
          return SetBoosterProgress(
            setId: set.setId,
            setName: set.setName,
            owned: set.owned,
            total: set.total,
            boosters: sortedBoosters,
          );
        })
        .toList()
      ..sort((a, b) => a.completionRatio.compareTo(b.completionRatio));
    return incomplete;
  }

  @override
  List<Object?> get props =>
      [totalOwned, totalCards, seriesStats, setBoosterProgress];
}

/// Complétion d'une série (ex: "A", "B", ou "Promo").
class SeriesStats extends Equatable {
  const SeriesStats({
    required this.seriesKey,
    required this.label,
    required this.owned,
    required this.total,
  });

  final String seriesKey;
  final String label;
  final int owned;
  final int total;

  double get completionRatio => total == 0 ? 0 : owned / total;
  bool get isComplete => total > 0 && owned >= total;

  @override
  List<Object?> get props => [seriesKey, label, owned, total];
}

/// Progression des boosters d'un set, en tenant compte des
/// recoupements entre boosters : une carte présente dans plusieurs
/// boosters d'un même set n'est comptée qu'une fois dans
/// [owned]/[total] (union, pas somme).
class SetBoosterProgress extends Equatable {
  const SetBoosterProgress({
    required this.setId,
    required this.setName,
    required this.owned,
    required this.total,
    required this.boosters,
  });

  final String setId;
  final String setName;

  /// Cartes possédées/existantes atteignables par au moins un
  /// booster de ce set. Les cartes hors-booster ("crossover rares",
  /// `PokemonCard.packs` vide) n'entrent dans aucun booster et ne
  /// comptent donc pas ici — contrairement au total du set utilisé
  /// ailleurs (`SeriesStats`, `CollectionStats.totalCards`), qui
  /// inclut toutes les cartes du set.
  final int owned;
  final int total;

  /// Détail par booster. Vide quand le set n'a qu'un seul booster :
  /// dans ce cas ce booster unique EST le set du point de vue des
  /// boosters, inutile de le répéter en dessous — voir
  /// [hasMultipleBoosters].
  final List<BoosterStats> boosters;

  bool get hasMultipleBoosters => boosters.length > 1;

  double get completionRatio => total == 0 ? 0 : owned / total;
  bool get isComplete => total > 0 && owned >= total;

  @override
  List<Object?> get props => [setId, setName, owned, total, boosters];
}

/// Complétion d'un booster précis d'un set précis (ex: le booster
/// "Mewtwo" du set "Genetic Apex").
class BoosterStats extends Equatable {
  const BoosterStats({
    required this.setId,
    required this.setName,
    required this.packName,
    required this.owned,
    required this.total,
  });

  final String setId;
  final String setName;
  final String packName;
  final int owned;
  final int total;

  double get completionRatio => total == 0 ? 0 : owned / total;
  bool get isComplete => total > 0 && owned >= total;

  @override
  List<Object?> get props => [setId, setName, packName, owned, total];
}