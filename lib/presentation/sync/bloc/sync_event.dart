import 'package:equatable/equatable.dart';

/// Événements gérés par [SyncBloc][sync_bloc.dart].
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché par "Synchroniser maintenant" ([SyncFirebaseAction]),
/// pour l'utilisateur connecté [userId].
class SyncRequested extends SyncEvent {
  const SyncRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Demande de (re)calcul du quota de synchronisations de [userId] :
/// à la connexion, à l'ouverture de l'accueil et à chaque ouverture du
/// menu de synchronisation, pour que le menu affiche un nombre restant
/// à jour.
class SyncQuotaRequested extends SyncEvent {
  const SyncQuotaRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
