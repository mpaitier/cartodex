import 'package:equatable/equatable.dart';

/// Événements gérés par [StatsBloc][stats_bloc.dart].
abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran : cherche le compte principal,
/// puis calcule ses statistiques.
class StatsStarted extends StatsEvent {
  const StatsStarted();
}