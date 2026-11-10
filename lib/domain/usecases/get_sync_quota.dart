import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../entities/sync_quota.dart';
import '../repositories/user_preferences_repository.dart';
import '../services/sync_rate_limit.dart';
import '../usecase.dart';

/// Synchronisations cloud encore possibles pour un compte applicatif,
/// d'après son historique sur l'appareil (voir [SyncRateLimit]).
///
/// Sert à l'affichage (nombre restant, heure de la prochaine
/// synchronisation possible). La limite elle-même est appliquée par
/// `SyncWithCloud`, qui ne dépend pas de ce que l'écran a affiché.
///
/// Un compte de [exemptUserIds] reçoit un quota illimité, sans lecture
/// de son historique.
class GetSyncQuota implements UseCase<SyncQuota, GetSyncQuotaParams> {
  GetSyncQuota(
    this._repository, {
    Set<String> exemptUserIds = const {},
    DateTime Function()? now,
  })  : _exemptUserIds = exemptUserIds,
        _now = now ?? DateTime.now;

  final UserPreferencesRepository _repository;
  final Set<String> _exemptUserIds;

  /// Horloge, remplaçable dans les tests.
  final DateTime Function() _now;

  @override
  Future<Either<Failure, SyncQuota>> call(GetSyncQuotaParams params) async {
    if (_exemptUserIds.contains(params.userId)) {
      return const Right(SyncQuota.unlimited());
    }
    final result = await _repository.getSyncHistory(params.userId);
    return result.map(
      (history) => SyncRateLimit.quotaFor(history, _now()),
    );
  }
}

/// Paramètre attendu par [GetSyncQuota].
class GetSyncQuotaParams extends Equatable {
  const GetSyncQuotaParams({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}
