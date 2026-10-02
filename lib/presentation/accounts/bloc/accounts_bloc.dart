import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/account_extras.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/add_account.dart';
import '../../../domain/usecases/get_accounts.dart';
import '../../../domain/usecases/get_secondary_accounts_extras.dart';
import '../../../domain/usecases/set_primary_account.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

/// ViewModel de l'écran de gestion des comptes.
///
/// Ajout et changement de compte principal rechargent tous les deux
/// la liste ensuite plutôt que de rapiécer l'état localement : ce
/// sont des opérations rares, la source de vérité reste la base
/// locale.
///
/// Charge aussi, pour chaque compte secondaire, les cartes qu'il a en
/// plus du principal (voir [GetSecondaryAccountsExtras]). Un échec de
/// ce calcul ne fait jamais tomber l'écran : les comptes s'affichent,
/// simplement sans compteurs.
///
/// Le critère de tri ([AccountsSortChanged]) est stocké dans l'état ;
/// l'ordre effectif est calculé par `AccountsState.sortedAccounts`.
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc({
    required GetAccounts getAccounts,
    required AddAccount addAccount,
    required SetPrimaryAccount setPrimaryAccount,
    required GetSecondaryAccountsExtras getSecondaryAccountsExtras,
  })  : _getAccounts = getAccounts,
        _addAccount = addAccount,
        _setPrimaryAccount = setPrimaryAccount,
        _getSecondaryAccountsExtras = getSecondaryAccountsExtras,
        super(const AccountsState()) {
    on<AccountsStarted>(_onStarted);
    on<AccountsRefreshRequested>(_onRefreshRequested);
    on<AccountsSortChanged>(_onSortChanged);
    on<AccountAdded>(_onAccountAdded);
    on<PrimaryAccountChanged>(_onPrimaryAccountChanged);
  }

  final GetAccounts _getAccounts;
  final AddAccount _addAccount;
  final SetPrimaryAccount _setPrimaryAccount;
  final GetSecondaryAccountsExtras _getSecondaryAccountsExtras;

  Future<void> _onStarted(
    AccountsStarted event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(status: AccountsStatus.loading));
    await _reload(emit);
  }

  Future<void> _onRefreshRequested(
    AccountsRefreshRequested event,
    Emitter<AccountsState> emit,
  ) async {
    // Tant que la liste n'est pas chargée, rien à rafraîchir : le
    // chargement initial calcule déjà tout.
    if (state.status != AccountsStatus.loaded) return;
    await _reload(emit);
  }

  void _onSortChanged(
    AccountsSortChanged event,
    Emitter<AccountsState> emit,
  ) {
    emit(state.copyWith(sortOption: event.option));
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
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: AccountsStatus.error,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    final accounts = result.getOrElse(() => const []);
    final extras = await _fetchExtras();
    emit(
      state.copyWith(
        status: AccountsStatus.loaded,
        accounts: accounts,
        extrasByAccountId: extras,
      ),
    );
  }

  /// Un calcul introuvable vaut une table vide, pas une erreur
  /// d'écran : voir la documentation de la classe.
  Future<Map<String, AccountExtras>> _fetchExtras() async {
    final result = await _getSecondaryAccountsExtras(const NoParams());
    return result.getOrElse(() => const <String, AccountExtras>{});
  }
}