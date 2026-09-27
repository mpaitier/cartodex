import 'package:equatable/equatable.dart';

/// Statistiques de complétion d'un compte, calculées par
/// `GetCollectionStats` : taux global, détail par série, et détail
/// par booster (pour savoir lesquels ouvrir en priorité — voir
/// [priorityBoosters]).
class CollectionStats extends Equatable {
  const CollectionStats({
    required this.totalOwned,
    required this.totalCards,
    required this.seriesStats,
    required this.boosterStats,
  });

  /// Cartes possédées, tous sets confondus.
  final int totalOwned;

  /// Cartes existantes, tous sets confondus.
  final int totalCards;

  /// Une entrée par série (regroupement identique à
  /// `SeriesFilterBar` : une série lettrée par entrée, plus un
  /// "Promo" combiné en dernier).
  final List<SeriesStats> seriesStats;

  /// Une entrée par booster de chaque set (un même nom de booster
  /// dans deux sets différents donne deux entrées distinctes).
  final List<BoosterStats> boosterStats;

  double get completionRatio => totalCards == 0 ? 0 : totalOwned / totalCards;

  /// Boosters pas encore complets, du moins avancé au plus avancé —
  /// les meilleurs candidats à ouvrir en priorité : plus un booster
  /// est loin d'être complet, plus une carte tirée dedans a de
  /// chances d'être encore manquante. Ignore les boosters déjà
  /// complets, qui n'ont plus rien à apporter.
  List<BoosterStats> get priorityBoosters {
    final incomplete = boosterStats.where((b) => !b.isComplete).toList()
      ..sort((a, b) => a.completionRatio.compareTo(b.completionRatio));
    return incomplete;
  }

  @override
  List<Object?> get props => [totalOwned, totalCards, seriesStats, boosterStats];
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