import 'package:equatable/equatable.dart';

import 'progress_count.dart';

/// Statistiques de complétion d'un compte, calculées par
/// `GetCollectionStats` : taux global, détail par série, et
/// progression des boosters par set (pour savoir lesquels ouvrir en
/// priorité — voir [CollectionStats.priorityBoosterProgressFor]).
///
/// Chaque progression est un [ProgressCount] "X (+Y) / Z" : X pour le
/// compte principal, Y pour ce que les comptes secondaires possèdent
/// en plus (sans doublon), Z pour le total.
class CollectionStats extends Equatable {
  const CollectionStats({
    required this.overall,
    required this.seriesStats,
    required this.setBoosterProgress,
  });

  /// Progression globale, tous sets confondus.
  final ProgressCount overall;

  /// Une entrée par série (regroupement identique à
  /// `SeriesFilterBar` : une série lettrée par entrée, puis "Deluxe"
  /// et "Promo" en dernier).
  final List<SeriesStats> seriesStats;

  /// Progression des boosters, par set — hors sets promotionnels et
  /// hors sets sans booster connu (voir `GetCollectionStats`). Sert
  /// de base à [priorityBoosterProgressFor].
  final List<SetBoosterProgress> setBoosterProgress;

  /// Les séries qui ont au moins un set avec des boosters, dans
  /// l'ordre de [seriesStats]. Ce sont les seules qu'on peut proposer
  /// comme filtre des boosters prioritaires : "Promo" n'y figure
  /// jamais, ses sets n'ayant pas de booster à ouvrir.
  List<SeriesStats> get boosterSeries {
    final keysWithBoosters = {
      for (final set in setBoosterProgress) set.seriesKey,
    };
    return seriesStats
        .where((series) => keysWithBoosters.contains(series.seriesKey))
        .toList();
  }

  /// Boosters à ouvrir en priorité, toutes séries confondues —
  /// raccourci de [priorityBoosterProgressFor] sans filtre.
  List<SetBoosterProgress> get priorityBoosterProgress =>
      priorityBoosterProgressFor(null);

  /// [setBoosterProgress] restreint aux sets pas encore complets côté
  /// boosters, du moins avancé au plus avancé — les meilleurs
  /// candidats à ouvrir en priorité : plus un set est loin d'être
  /// complet, plus une carte tirée dans l'un de ses boosters a de
  /// chances d'être encore manquante. À l'intérieur d'un set à
  /// plusieurs boosters, ceux-ci sont eux aussi triés du moins avancé
  /// au plus avancé, pour indiquer lequel ouvrir en premier au sein
  /// du set.
  ///
  /// Quand [seriesKey] est fourni, seuls les sets de cette série
  /// (voir [SeriesStats.seriesKey]) sont gardés ; `null` garde toutes
  /// les séries.
  ///
  /// Le tri ne regarde que le compte principal ([ProgressCount.owned]) :
  /// les cartes des secondaires ne rendent pas un booster moins utile
  /// au principal.
  List<SetBoosterProgress> priorityBoosterProgressFor(String? seriesKey) {
    final incomplete = setBoosterProgress
        .where((set) => seriesKey == null || set.seriesKey == seriesKey)
        .where((set) => !set.isComplete)
        .map((set) {
          if (!set.hasMultipleBoosters) return set;
          final sortedBoosters = List<BoosterStats>.from(set.boosters)
            ..sort(
              (a, b) =>
                  a.progress.primaryRatio.compareTo(b.progress.primaryRatio),
            );
          return set.copyWith(boosters: sortedBoosters);
        })
        .toList()
      ..sort(
        (a, b) => a.progress.primaryRatio.compareTo(b.progress.primaryRatio),
      );
    return incomplete;
  }

  @override
  List<Object?> get props => [overall, seriesStats, setBoosterProgress];
}

/// Complétion d'une série (ex: "A", "B", "Deluxe" ou "Promo").
class SeriesStats extends Equatable {
  const SeriesStats({
    required this.seriesKey,
    required this.label,
    required this.progress,
  });

  final String seriesKey;
  final String label;
  final ProgressCount progress;

  bool get isComplete => progress.isComplete;

  @override
  List<Object?> get props => [seriesKey, label, progress];
}

/// Progression des boosters d'un set, en tenant compte des
/// recoupements entre boosters : une carte présente dans plusieurs
/// boosters d'un même set n'est comptée qu'une fois dans
/// [progress] (union, pas somme).
class SetBoosterProgress extends Equatable {
  const SetBoosterProgress({
    required this.setId,
    required this.setName,
    required this.seriesKey,
    required this.progress,
    required this.boosters,
  });

  final String setId;
  final String setName;

  /// Série à laquelle le set est rattaché, avec la même clé que
  /// [SeriesStats.seriesKey] ("A", "B", "DELUXE"…). Permet de filtrer
  /// les boosters prioritaires par série.
  final String seriesKey;

  /// Cartes atteignables par au moins un booster de ce set. Les
  /// cartes hors-booster ("crossover rares", `PokemonCard.packs`
  /// vide) n'entrent dans aucun booster et ne comptent donc pas ici
  /// — contrairement au total du set utilisé ailleurs (`SeriesStats`,
  /// `CollectionStats.overall`), qui inclut toutes les cartes.
  final ProgressCount progress;

  /// Détail par booster. Un set à un seul booster n'en a qu'un : ce
  /// booster unique EST le set du point de vue des boosters, inutile
  /// de le répéter en dessous — voir [hasMultipleBoosters].
  final List<BoosterStats> boosters;

  bool get hasMultipleBoosters => boosters.length > 1;

  bool get isComplete => progress.isComplete;

  SetBoosterProgress copyWith({List<BoosterStats>? boosters}) {
    return SetBoosterProgress(
      setId: setId,
      setName: setName,
      seriesKey: seriesKey,
      progress: progress,
      boosters: boosters ?? this.boosters,
    );
  }

  @override
  List<Object?> get props => [setId, setName, seriesKey, progress, boosters];
}

/// Complétion d'un booster précis d'un set précis (ex: le booster
/// "Mewtwo" du set "Genetic Apex").
class BoosterStats extends Equatable {
  const BoosterStats({
    required this.setId,
    required this.setName,
    required this.packName,
    required this.progress,
  });

  final String setId;
  final String setName;
  final String packName;
  final ProgressCount progress;

  bool get isComplete => progress.isComplete;

  @override
  List<Object?> get props => [setId, setName, packName, progress];
}
