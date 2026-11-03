import 'package:equatable/equatable.dart';

import 'card_set.dart';
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
  /// boosters, du plus intéressant au moins intéressant à ouvrir.
  ///
  /// Le critère est l'espérance de cartes manquantes par ouverture
  /// ([BoosterStats.expectedNewCards], voir `BoosterExpectedValue`) :
  /// nombre de cartes manquantes de chaque rareté × probabilité de
  /// tirer cette rareté. Un set se classe selon son meilleur booster
  /// ([SetBoosterProgress.expectedNewCards]), puisqu'on n'en ouvre
  /// qu'un à la fois ; à l'intérieur d'un set à plusieurs boosters,
  /// ceux-ci sont triés de la même façon, pour indiquer lequel ouvrir
  /// en premier.
  ///
  /// Les sets et boosters sans probabilités connues (référentiel pas
  /// encore resynchronisé, set absent de la source) passent après les
  /// autres, du moins avancé au plus avancé : l'ancien critère, à
  /// défaut de mieux.
  ///
  /// Quand [seriesKey] est fourni, seuls les sets de cette série
  /// (voir [SeriesStats.seriesKey]) sont gardés ; `null` garde toutes
  /// les séries.
  ///
  /// Seul le compte principal compte, pour l'espérance comme pour la
  /// progression ([ProgressCount.owned]) : les cartes des secondaires
  /// ne rendent pas un booster moins utile au principal.
  List<SetBoosterProgress> priorityBoosterProgressFor(String? seriesKey) {
    final incomplete = setBoosterProgress
        .where((set) => seriesKey == null || set.seriesKey == seriesKey)
        .where((set) => !set.isComplete)
        .map((set) {
          if (!set.hasMultipleBoosters) return set;
          final sortedBoosters = List<BoosterStats>.from(set.boosters)
            ..sort(
              (a, b) => _comparePriority(
                a.expectedNewCards,
                a.progress,
                b.expectedNewCards,
                b.progress,
              ),
            );
          return set.copyWith(boosters: sortedBoosters);
        })
        .toList()
      ..sort(
        (a, b) => _comparePriority(
          a.expectedNewCards,
          a.progress,
          b.expectedNewCards,
          b.progress,
        ),
      );
    return incomplete;
  }

  /// Ordre de priorité entre deux boosters (ou deux sets) : la plus
  /// forte espérance d'abord ; sans espérance connue, après les
  /// autres, puis du moins avancé au plus avancé.
  static int _comparePriority(
    double? expectedA,
    ProgressCount progressA,
    double? expectedB,
    ProgressCount progressB,
  ) {
    if (expectedA != null && expectedB != null) {
      final byExpected = expectedB.compareTo(expectedA);
      if (byExpected != 0) return byExpected;
    } else if (expectedA != null) {
      return -1;
    } else if (expectedB != null) {
      return 1;
    }
    return progressA.primaryRatio.compareTo(progressB.primaryRatio);
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
    required this.set,
    required this.seriesKey,
    required this.progress,
    required this.boosters,
  });

  /// Le set lui-même, gardé en entier plutôt que son seul
  /// identifiant : l'écran de statistiques l'ouvre tel quel dans le
  /// détail d'un set (`SetDetailPage`), qui attend un [CardSet].
  final CardSet set;

  String get setId => set.id;

  String get setName => set.name;

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

  /// Espérance de cartes manquantes par ouverture du meilleur booster
  /// du set — celui qu'on ouvrirait. `null` quand aucun booster n'a de
  /// probabilités connues.
  double? get expectedNewCards {
    double? best;
    for (final booster in boosters) {
      final expected = booster.expectedNewCards;
      if (expected == null) continue;
      if (best == null || expected > best) best = expected;
    }
    return best;
  }

  SetBoosterProgress copyWith({List<BoosterStats>? boosters}) {
    return SetBoosterProgress(
      set: set,
      seriesKey: seriesKey,
      progress: progress,
      boosters: boosters ?? this.boosters,
    );
  }

  @override
  List<Object?> get props => [set, seriesKey, progress, boosters];
}

/// Complétion d'un booster précis d'un set précis (ex: le booster
/// "Mewtwo" du set "Genetic Apex").
class BoosterStats extends Equatable {
  const BoosterStats({
    required this.setId,
    required this.setName,
    required this.packName,
    required this.progress,
    this.expectedNewCards,
  });

  final String setId;
  final String setName;
  final String packName;
  final ProgressCount progress;

  /// Nombre moyen de cartes manquantes au compte principal obtenues
  /// en ouvrant ce booster une fois (voir `BoosterExpectedValue`),
  /// dans le périmètre de raretés des statistiques. `null` quand les
  /// probabilités de tirage du set ne sont pas connues.
  final double? expectedNewCards;

  bool get isComplete => progress.isComplete;

  @override
  List<Object?> get props =>
      [setId, setName, packName, progress, expectedNewCards];
}
