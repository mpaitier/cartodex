import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/sync_quota.dart';
import '../../../domain/usecases/get_sync_quota.dart';
import '../../../domain/usecases/sync_with_cloud.dart';
import 'sync_event.dart';
import 'sync_state.dart';

/// ViewModel de la synchronisation avec le compte applicatif
/// (Firebase) — voir [SyncFirebaseAction][../../card_sets/widgets/sync_firebase_action.dart].
///
/// Tient aussi le quota de synchronisations restant ([SyncState.quota]),
/// recalculé après chaque synchronisation pour que le menu le reflète
/// aussitôt.
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required SyncWithCloud syncWithCloud,
    required GetSyncQuota getSyncQuota,
  })  : _syncWithCloud = syncWithCloud,
        _getSyncQuota = getSyncQuota,
        super(const SyncState()) {
    on<SyncRequested>(_onSyncRequested);
    on<SyncQuotaRequested>(_onSyncQuotaRequested);
  }

  final SyncWithCloud _syncWithCloud;
  final GetSyncQuota _getSyncQuota;

  Future<void> _onSyncRequested(
    SyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(state.copyWith(status: SyncStatus.syncing));
    final result =
        await _syncWithCloud(SyncWithCloudParams(userId: event.userId));
    final quota = await _loadQuota(event.userId);
    result.fold(
      (failure) {
        if (failure is SyncQuotaExceededFailure) {
          emit(
            state.copyWith(
              status: SyncStatus.quotaExceeded,
              quota: quota ??
                  SyncQuota(
                    remaining: 0,
                    nextAvailableAt: failure.nextAvailableAt,
                  ),
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: SyncStatus.error,
            errorMessage: failure.message,
            quota: quota,
          ),
        );
      },
      (syncResult) => emit(
        state.copyWith(
          status: SyncStatus.success,
          result: syncResult,
          quota: quota,
        ),
      ),
    );
  }

  /// Recalcule le quota en gardant le statut. Le bilan et le message
  /// d'erreur sont effacés (voir [SyncState.copyWith]) : ils ont déjà
  /// été affichés, et ne doivent pas l'être une seconde fois. Un échec
  /// de lecture laisse le quota précédent en place : le menu reste
  /// utilisable, et `SyncWithCloud` applique la limite de toute façon.
  Future<void> _onSyncQuotaRequested(
    SyncQuotaRequested event,
    Emitter<SyncState> emit,
  ) async {
    final quota = await _loadQuota(event.userId);
    if (quota != null && quota != state.quota) {
      emit(state.copyWith(quota: quota));
    }
  }

  Future<SyncQuota?> _loadQuota(String userId) async {
    final result = await _getSyncQuota(GetSyncQuotaParams(userId: userId));
    return result.fold((_) => null, (quota) => quota);
  }
}
