import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_accounts.dart';
import '../../../domain/usecases/get_collection_stats.dart';
import 'stats_event.dart';
import 'stats_state.dart';

/// ViewModel de l'écran de statistiques.
///
/// Cherche d'abord les comptes (même logique que
/// [SetDetailBloc][../../set_detail/bloc/set_detail_bloc.dart]) avant
/// de calculer les statistiques : sans compte créé, il n'y a rien à
/// afficher. Les statistiques sont celles du compte principal (X) ;
/// les comptes secondaires n'apportent que ce que le principal n'a
/// pas déjà (+Y).
///
/// Un changement de périmètre de raretés ([StatsRarityScopeChanged])
/// recalcule sans repasser par l'état de chargement : les chiffres
/// précédents restent affichés le temps du calcul, pas d'écran vide
/// à chaque appui sur le bouton.
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required GetAccounts getAccounts,
    required GetCollectionStats getCollectionStats,
  })  : _getAccounts = getAccounts,
        _getCollectionStats = getCollectionStats,
        super(const StatsState()) {
    on<StatsStarted>(_onStarted);
    on<StatsRarityScopeChanged>(_onRarityScopeChanged);
  }

  final GetAccounts _getAccounts;
  final GetCollectionStats _getCollectionStats;

  Future<void> _onStarted(StatsStarted event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));
    await _load(emit);
  }

  Future<void> _onRarityScopeChanged(
    StatsRarityScopeChanged event,
    Emitter<StatsState> emit,
  ) async {
    if (event.scope == state.rarityScope) return;
    emit(state.copyWith(rarityScope: event.scope));
    await _load(emit);
  }

  Future<void> _load(Emitter<StatsState> emit) async {
    final scope = state.rarityScope;

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

    final accounts = accountsResult.getOrElse(() => const <Account>[]);
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
      GetCollectionStatsParams(
        primaryAccountId: primary.id,
        secondaryAccountIds: [
          for (final account in accounts)
            if (!account.isPrimary) account.id,
        ],
        rarityScope: scope,
      ),
    );

    // Les événements d'un Bloc sont traités en parallèle : si le
    // périmètre a encore changé pendant ce calcul, un résultat plus
    // récent est en route — on jette celui-ci plutôt que de risquer
    // d'afficher des chiffres d'un ancien périmètre.
    if (state.rarityScope != scope) return;

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