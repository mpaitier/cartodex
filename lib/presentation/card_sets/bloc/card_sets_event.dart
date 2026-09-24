import 'package:equatable/equatable.dart';

/// Événements gérés par [CardSetsBloc][card_sets_bloc.dart].
abstract class CardSetsEvent extends Equatable {
  const CardSetsEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran : charge les sets déjà
/// présents dans le référentiel local, sans appeler l'API.
class CardSetsStarted extends CardSetsEvent {
  const CardSetsStarted();
}

/// Déclenché par l'utilisateur (action de synchronisation) :
/// télécharge le référentiel distant avant de recharger les sets
/// locaux.
class CardSetsSyncRequested extends CardSetsEvent {
  const CardSetsSyncRequested();
}

/// Déclenché par la sélection d'un onglet dans
/// [SeriesFilterBar][../widgets/series_filter_bar.dart].
class SeriesFilterChanged extends CardSetsEvent {
  const SeriesFilterChanged(this.seriesKey);

  final String seriesKey;

  @override
  List<Object?> get props => [seriesKey];
}