import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/account_extras.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_secondary_accounts_extras.dart';
import '../../../domain/usecases/update_account.dart';
import 'account_extras_event.dart';
import 'account_extras_state.dart';

/// ViewModel de l'écran des cartes qu'un compte secondaire possède en
/// plus du compte principal, set par set.
///
/// S'appuie sur [GetSecondaryAccountsExtras] (qui calcule tous les
/// secondaires d'un coup) et en extrait le compte concerné : un compte
/// absent de la table n'a simplement aucune carte en plus.
///
/// Permet aussi de modifier le nom et le code ami du compte affiché
/// ([UpdateAccount]). Un échec ne fait pas tomber l'écran : il est
/// remonté dans `errorMessage` avec le statut inchangé, pour un simple
/// message.
class AccountExtrasBloc extends Bloc<AccountExtrasEvent, AccountExtrasState> {
  AccountExtrasBloc({
    required GetSecondaryAccountsExtras getSecondaryAccountsExtras,
    required UpdateAccount updateAccount,
  })  : _getSecondaryAccountsExtras = getSecondaryAccountsExtras,
        _updateAccount = updateAccount,
        super(const AccountExtrasState()) {
    on<AccountExtrasStarted>(_onStarted);
    on<AccountExtrasRefreshRequested>(_onRefreshRequested);
    on<AccountExtrasAccountEdited>(_onAccountEdited);
  }

  final GetSecondaryAccountsExtras _getSecondaryAccountsExtras;
  final UpdateAccount _updateAccount;

  Future<void> _onStarted(
    AccountExtrasStarted event,
    Emitter<AccountExtrasState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AccountExtrasStatus.loading,
        account: event.account,
      ),
    );
    await _load(event.account.id, emit);
  }

  Future<void> _onAccountEdited(
    AccountExtrasAccountEdited event,
    Emitter<AccountExtrasState> emit,
  ) async {
    final account = state.account;
    if (account == null) return;
    final result = await _updateAccount(
      UpdateAccountParams(
        accountId: account.id,
        name: event.name,
        gameAccountId: event.gameAccountId,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(
        state.copyWith(
          account: account.copyWith(
            name: event.name,
            gameAccountId: event.gameAccountId,
          ),
        ),
      ),
    );
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