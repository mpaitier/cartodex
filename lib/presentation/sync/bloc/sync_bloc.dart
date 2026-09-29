import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/sync_with_cloud.dart';
import 'sync_event.dart';
import 'sync_state.dart';

/// ViewModel de la synchronisation avec le compte applicatif
/// (Firebase) — voir [SyncFirebaseAction][../../card_sets/widgets/sync_firebase_action.dart].
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({required SyncWithCloud syncWithCloud})
      : _syncWithCloud = syncWithCloud,
        super(const SyncState()) {
    on<SyncRequested>(_onSyncRequested);
  }

  final SyncWithCloud _syncWithCloud;

  Future<void> _onSyncRequested(
    SyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(state.copyWith(status: SyncStatus.syncing));
    final result =
        await _syncWithCloud(SyncWithCloudParams(userId: event.userId));
    result.fold(
      (failure) => emit(
        state.copyWith(status: SyncStatus.error, errorMessage: failure.message),
      ),
      (syncResult) =>
          emit(state.copyWith(status: SyncStatus.success, result: syncResult)),
    );
  }
}