import 'package:equatable/equatable.dart';

import '../../../domain/entities/collection_stats.dart';
import '../../../domain/entities/rarity_scope.dart';

/// Étape du cycle de vie de [StatsState].
enum StatsStatus {
  /// Aucun chargement n'a encore été déclenché.
  initial,

  /// Recherche des comptes et calcul des statistiques en cours.
  loading,

  /// Statistiques calculées.
  loaded,

  /// Aucun compte n'existe encore : rien à calculer.
  noAccount,

  /// Échec du chargement.
  error,
}

/// État affiché par l'écran de statistiques.
class StatsState extends Equatable {
  const StatsState({
    this.status = StatsStatus.initial,
    this.stats,
    this.rarityScope = RarityScope.all,
    this.boosterSeriesKey,
    this.errorMessage,
  });

  final StatsStatus status;
  final CollectionStats? stats;

  /// Périmètre de raretés des statistiques affichées. Rond (toutes)
  /// par défaut.
  final RarityScope rarityScope;

  /// Série choisie pour les boosters à ouvrir en priorité (clé de
  /// `SeriesStats.seriesKey`). `null` = toutes les séries, le choix
  /// par défaut.
  final String? boosterSeriesKey;

  final String? errorMessage;

  /// Les séries proposées dans le sélecteur des boosters prioritaires.
  List<SeriesStats> get boosterSeries =>
      stats?.boosterSeries ?? const <SeriesStats>[];

  /// [boosterSeriesKey] si cette série fait encore partie de
  /// [boosterSeries], `null` (toutes les séries) sinon. Évite de
  /// rester bloqué sur un filtre qui ne correspond plus à rien, par
  /// exemple après un changement de périmètre de raretés.
  String? get effectiveBoosterSeriesKey {
    final key = boosterSeriesKey;
    if (key == null) return null;
    final stillAvailable = boosterSeries.any((s) => s.seriesKey == key);
    return stillAvailable ? key : null;
  }

  /// Boosters à ouvrir en priorité, filtrés selon
  /// [effectiveBoosterSeriesKey].
  List<SetBoosterProgress> get priorityBoosters =>
      stats?.priorityBoosterProgressFor(effectiveBoosterSeriesKey) ??
      const <SetBoosterProgress>[];

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  ///
  /// [boosterSeriesKey] étant nullable, revenir à "toutes les
  /// séries" passe par [clearBoosterSeriesKey].
  StatsState copyWith({
    StatsStatus? status,
    CollectionStats? stats,
    RarityScope? rarityScope,
    String? boosterSeriesKey,
    bool clearBoosterSeriesKey = false,
    String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      rarityScope: rarityScope ?? this.rarityScope,
      boosterSeriesKey: clearBoosterSeriesKey
          ? null
          : boosterSeriesKey ?? this.boosterSeriesKey,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, stats, rarityScope, boosterSeriesKey, errorMessage];
}
