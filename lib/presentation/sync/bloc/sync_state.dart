import 'package:equatable/equatable.dart';

import '../../../domain/entities/sync_result.dart';

/// Étape du cycle de vie de [SyncState].
enum SyncStatus {
  /// Aucune synchronisation en cours ni terminée depuis l'ouverture
  /// de l'écran.
  idle,

  syncing,
  success,

  /// Échec de la synchronisation.
  error,
}

/// État de la synchronisation avec le compte applicatif (Firebase).
class SyncState extends Equatable {
  const SyncState({
    this.status = SyncStatus.idle,
    this.result,
    this.errorMessage,
  });

  final SyncStatus status;

  /// Bilan de la dernière synchronisation réussie — voir
  /// [SyncResult].
  final SyncResult? result;

  final String? errorMessage;

  /// Ne préserve jamais l'ancien résultat/message d'erreur : toute
  /// transition qui ne les fournit pas explicitement les
  /// réinitialise, pour ne pas réafficher un bilan déjà périmé.
  SyncState copyWith({
    SyncStatus? status,
    SyncResult? result,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      result: result,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}