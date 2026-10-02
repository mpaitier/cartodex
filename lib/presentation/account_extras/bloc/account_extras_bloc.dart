import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/account_extras.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_secondary_accounts_extras.dart';
import 'account_extras_event.dart';
import 'account_extras_state.dart';

/// ViewModel de l'écran des cartes qu'un compte secondaire possède en
/// plus du compte principal, set par set.
///
/// S'appuie sur [GetSecondaryAccountsExtras] (qui calcule tous les
/// secondaires d'un coup) et en extrait le compte concerné : un compte
/// absent de la table n'a simplement aucune carte en plus.
class AccountExtrasBloc extends Bloc<AccountExtrasEvent, AccountExtrasState> {
  AccountExtrasBloc({
    required GetSecondaryAccountsExtras getSecondaryAccountsExtras,
  })  : _getSecondaryAccountsExtras = getSecondaryAccountsExtras,
        super(const AccountExtrasState()) {
    on<AccountExtrasStarted>(_onStarted);
    on<AccountExtrasRefreshRequested>(_onRefreshRequested);
  }

  final GetSecondaryAccountsExtras _getSecondaryAccountsExtras;

  Future<void> _onStarted(
    AccountExtrasStarted event,
    Emitter<AccountExtrasState> emit,
  ) async {
    emit(state.copyWith(status: AccountExtrasStatus.loading));
    await _load(event.accountId, emit);
  }

  Future<void> _onRefreshRequested(
    AccountExtrasRefreshRequested event,
    Emitter<AccountExtrasState> emit,
  ) async {
    // Tant que rien n'est chargé, rien à rafraîchir : le chargement
    // initial calcule déjà tout.
    if (state.status != AccountExtrasStatus.loaded) return;
    await _load(event.accountId, emit);
  }

  Future<void> _load(
    String accountId,
    Emitter<AccountExtrasState> emit,
  ) async {
    final result = await _getSecondaryAccountsExtras(const NoParams());
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: AccountExtrasStatus.error,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    final byAccountId =
        result.getOrElse(() => const <String, AccountExtras>{});
    emit(
      state.copyWith(
        status: AccountExtrasStatus.loaded,
        extras: byAccountId[accountId] ?? AccountExtras(accountId: accountId),
      ),
    );
  }
}