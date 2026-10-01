import 'package:equatable/equatable.dart';

import '../../../domain/entities/rarity_scope.dart';

/// Événements gérés par [StatsBloc][stats_bloc.dart].
abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran : cherche le compte principal
/// et les secondaires, puis calcule les statistiques.
class StatsStarted extends StatsEvent {
  const StatsStarted();
}

/// Déclenché par le bouton de la top bar : change le périmètre de
/// raretés (rond = toutes, losange, étoile) et recalcule.
class StatsRarityScopeChanged extends StatsEvent {
  const StatsRarityScopeChanged(this.scope);

  final RarityScope scope;

  @override
  List<Object?> get props => [scope];
}