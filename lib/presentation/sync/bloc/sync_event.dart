import 'package:equatable/equatable.dart';

/// Événements gérés par [SyncBloc][sync_bloc.dart].
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché par "Synchroniser maintenant" dans les paramètres
/// (`CloudSyncTile`), pour l'utilisateur connecté [userId].
class SyncRequested extends SyncEvent {
  const SyncRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Demande de (re)calcul du quota de synchronisations de [userId] :
/// à la connexion, à l'ouverture de l'accueil et à chaque ouverture des
/// paramètres, pour que ceux-ci affichent un nombre restant à jour.
class SyncQuotaRequested extends SyncEvent {
  const SyncQuotaRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
