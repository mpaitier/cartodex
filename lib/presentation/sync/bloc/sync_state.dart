import 'package:equatable/equatable.dart';

import '../../../domain/entities/sync_quota.dart';
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

  /// Synchronisation refusée : la limite de la période est atteinte
  /// (voir [SyncState.quota] pour l'heure de la prochaine).
  quotaExceeded,
}

/// État de la synchronisation avec le compte applicatif (Firebase).
class SyncState extends Equatable {
  const SyncState({
    this.status = SyncStatus.idle,
    this.result,
    this.errorMessage,
    this.quota,
  });

  final SyncStatus status;

  /// Bilan de la dernière synchronisation réussie — voir
  /// [SyncResult].
  final SyncResult? result;

  final String? errorMessage;

  /// Synchronisations encore possibles pour l'utilisateur connecté,
  /// `null` tant qu'elles n'ont pas été calculées.
  final SyncQuota? quota;

  /// Ne préserve jamais l'ancien résultat/message d'erreur : toute
  /// transition qui ne les fournit pas explicitement les
  /// réinitialise, pour ne pas réafficher un bilan déjà périmé. Le
  /// quota, lui, est conservé tant qu'un nouveau ne le remplace pas.
  SyncState copyWith({
    SyncStatus? status,
    SyncResult? result,
    String? errorMessage,
    SyncQuota? quota,
  }) {
    return SyncState(
      status: status ?? this.status,
      result: result,
      errorMessage: errorMessage,
      quota: quota ?? this.quota,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage, quota];
}
