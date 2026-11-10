import 'package:equatable/equatable.dart';

import '../../../domain/entities/rarity_scope.dart';

/// Événements gérés par [StatsBloc][stats_bloc.dart].
abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran : cherche le compte principal
/// et les secondaires, puis calcule les statistiques dans le périmètre
/// [rarityScope] — celui de l'app au moment de l'ouverture
/// (`RarityScopeCubit`).
class StatsStarted extends StatsEvent {
  const StatsStarted({this.rarityScope = RarityScope.all});

  final RarityScope rarityScope;

  @override
  List<Object?> get props => [rarityScope];
}

/// Déclenché au retour du détail d'un set ouvert depuis les boosters
/// prioritaires : la possession a pu y changer. Recalcule les
/// statistiques sans repasser par l'état de chargement, pour ne pas
/// vider l'écran à chaque retour.
class StatsRefreshRequested extends StatsEvent {
  const StatsRefreshRequested();
}

/// Déclenché quand le périmètre de raretés global change (Σ = toutes,
/// losange, étoile), que ce soit depuis le bouton de la top bar ou
/// depuis un autre écran encore ouvert au-dessus : recalcule.
class StatsRarityScopeChanged extends StatsEvent {
  const StatsRarityScopeChanged(this.scope);

  final RarityScope scope;

  @override
  List<Object?> get props => [scope];
}

/// Déclenché par le sélecteur de série de la section "Boosters à
/// ouvrir en priorité" : restreint cette liste à une série.
///
/// [seriesKey] reprend `SeriesStats.seriesKey` ("A", "B",
/// "DELUXE"…) ; `null` revient à toutes les séries. Simple filtre
/// d'affichage, aucun recalcul des statistiques.
class StatsBoosterSeriesSelected extends StatsEvent {
  const StatsBoosterSeriesSelected(this.seriesKey);

  final String? seriesKey;

  @override
  List<Object?> get props => [seriesKey];
}
