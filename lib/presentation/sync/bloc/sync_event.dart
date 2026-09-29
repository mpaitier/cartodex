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