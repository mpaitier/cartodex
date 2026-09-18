import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecase.dart';
import '../../../domain/usecases/add_account.dart';
import '../../../domain/usecases/get_accounts.dart';
import '../../../domain/usecases/set_primary_account.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

/// ViewModel de l'écran de gestion des comptes.
///
/// Ajout et changement de compte principal rechargent tous les deux
/// la liste ensuite plutôt que de rapiécer l'état localement : ce
/// sont des opérations rares, la source de vérité reste la base
/// locale.
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc({
    required GetAccounts getAccounts,
    required AddAccount addAccount,
    required SetPrimaryAccount setPrimaryAccount,
  })  : _getAccounts = getAccounts,
        _addAccount = addAccount,
        _setPrimaryAccount = setPrimaryAccount,
        super(const AccountsState()) {
    on<AccountsStarted>(_onStarted);
    on<AccountAdded>(_onAccountAdded);
    on<PrimaryAccountChanged>(_onPrimaryAccountChanged);
  }

  final GetAccounts _getAccounts;
  final AddAccount _addAccount;
  final SetPrimaryAccount _setPrimaryAccount;

  Future<void> _onStarted(
    AccountsStarted event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(status: AccountsStatus.loading));
    await _reload(emit);
  }

  Future<void> _onAccountAdded(
    AccountAdded event,
    Emitter<AccountsState> emit,
  ) async {
    final result = await _addAccount(
      AddAccountParams(name: event.name, gameAccountId: event.gameAccountId),
    );
    await result.fold(
      (failure) async =>
          emit(state.copyWith(errorMessage: failure.message)),
      (_) => _reload(emit),
    );
  }

  Future<void> _onPrimaryAccountChanged(
    PrimaryAccountChanged event,
    Emitter<AccountsState> emit,
  ) async {
    final result = await _setPrimaryAccount(
      SetPrimaryAccountParams(accountId: event.accountId),
    );
    await result.fold(
      (failure) async =>
          emit(state.copyWith(errorMessage: failure.message)),
      (_) => _reload(emit),
    );
  }

  Future<void> _reload(Emitter<AccountsState> emit) async {
    final result = await _getAccounts(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AccountsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (accounts) => emit(
        state.copyWith(status: AccountsStatus.loaded, accounts: accounts),
      ),
    );
  }
}