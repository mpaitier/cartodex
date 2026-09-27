import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_accounts.dart';
import '../../../domain/usecases/get_collection_stats.dart';
import 'stats_event.dart';
import 'stats_state.dart';

/// ViewModel de l'écran de statistiques.
///
/// Cherche d'abord le compte principal (même logique que
/// [SetDetailBloc][../../set_detail/bloc/set_detail_bloc.dart]) avant
/// de calculer ses statistiques : sans compte créé, il n'y a rien à
/// afficher.
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required GetAccounts getAccounts,
    required GetCollectionStats getCollectionStats,
  })  : _getAccounts = getAccounts,
        _getCollectionStats = getCollectionStats,
        super(const StatsState()) {
    on<StatsStarted>(_onStarted);
  }

  final GetAccounts _getAccounts;
  final GetCollectionStats _getCollectionStats;

  Future<void> _onStarted(StatsStarted event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));

    final accountsResult = await _getAccounts(const NoParams());
    final accountsFailure = accountsResult.fold((f) => f, (_) => null);
    if (accountsFailure != null) {
      emit(
        state.copyWith(
          status: StatsStatus.error,
          errorMessage: accountsFailure.message,
        ),
      );
      return;
    }

    final accounts = accountsResult.getOrElse(() => const []);
    Account? primary;
    for (final account in accounts) {
      if (account.isPrimary) {
        primary = account;
        break;
      }
    }
    if (primary == null) {
      emit(state.copyWith(status: StatsStatus.noAccount));
      return;
    }

    final statsResult = await _getCollectionStats(
      GetCollectionStatsParams(accountId: primary.id),
    );
    statsResult.fold(
      (failure) => emit(
        state.copyWith(
          status: StatsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (stats) =>
          emit(state.copyWith(status: StatsStatus.loaded, stats: stats)),
    );
  }
}