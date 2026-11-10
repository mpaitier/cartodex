import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/account_extras.dart';
import '../../../domain/entities/accounts_sort_option.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/add_account.dart';
import '../../../domain/usecases/get_accounts.dart';
import '../../../domain/usecases/get_accounts_sort_option.dart';
import '../../../domain/usecases/get_secondary_accounts_extras.dart';
import '../../../domain/usecases/save_accounts_sort_option.dart';
import '../../../domain/usecases/set_primary_account.dart';
import '../../../domain/usecases/update_account.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

/// ViewModel de l'écran de gestion des comptes.
///
/// Ajout, modification et changement de compte principal rechargent
/// la liste ensuite plutôt que de rapiécer l'état localement : ce sont
/// des opérations rares, la source de vérité reste la base locale.
///
/// Charge aussi, pour chaque compte secondaire, les cartes qu'il a en
/// plus du principal (voir [GetSecondaryAccountsExtras]). Un échec de
/// ce calcul ne fait jamais tomber l'écran : les comptes s'affichent,
/// simplement sans compteurs.
///
/// Le filtre par extension ([AccountsSetFilterChanged]) vit seulement
/// dans l'état, le temps de l'écran.
///
/// Le critère de tri ([AccountsSortChanged]) est stocké dans l'état ;
/// l'ordre effectif est calculé par `AccountsState.sortedAccounts`. Il
/// est relu à l'ouverture de l'écran ([GetAccountsSortOption]) et
/// enregistré à chaque changement ([SaveAccountsSortOption]). Ni la
/// lecture ni l'enregistrement ne bloquent l'écran en cas d'échec : le
/// tri retombe sur l'ordre de création, ou n'est simplement pas
/// mémorisé.
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc({
    required GetAccounts getAccounts,
    required AddAccount addAccount,
    required UpdateAccount updateAccount,
    required SetPrimaryAccount setPrimaryAccount,
    required GetSecondaryAccountsExtras getSecondaryAccountsExtras,
    required GetAccountsSortOption getAccountsSortOption,
    required SaveAccountsSortOption saveAccountsSortOption,
  })  : _getAccounts = getAccounts,
        _addAccount = addAccount,
        _updateAccount = updateAccount,
        _setPrimaryAccount = setPrimaryAccount,
        _getSecondaryAccountsExtras = getSecondaryAccountsExtras,
        _getAccountsSortOption = getAccountsSortOption,
        _saveAccountsSortOption = saveAccountsSortOption,
        super(const AccountsState()) {
    on<AccountsStarted>(_onStarted);
    on<AccountsRefreshRequested>(_onRefreshRequested);
    on<AccountsSortChanged>(_onSortChanged);
    on<AccountsSetFilterChanged>(_onSetFilterChanged);
    on<AccountAdded>(_onAccountAdded);
    on<AccountEdited>(_onAccountEdited);
    on<PrimaryAccountChanged>(_onPrimaryAccountChanged);
  }

  final GetAccounts _getAccounts;
  final AddAccount _addAccount;
  final UpdateAccount _updateAccount;
  final SetPrimaryAccount _setPrimaryAccount;
  final GetSecondaryAccountsExtras _getSecondaryAccountsExtras;
  final GetAccountsSortOption _getAccountsSortOption;
  final SaveAccountsSortOption _saveAccountsSortOption;

  Future<void> _onStarted(
    AccountsStarted event,
    Emitter<AccountsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AccountsStatus.loading,
        sortOption: await _readSavedSortOption(),
      ),
    );
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

  Future<void> _onSortChanged(
    AccountsSortChanged event,
    Emitter<AccountsState> emit,
  ) async {
    if (event.option == state.sortOption) return;
    emit(state.copyWith(sortOption: event.option));

    final result = await _saveAccountsSortOption(event.option);
    result.fold(
      (failure) => AppLogger.log(
        'WARNING',
        'Tri des comptes non mémorisé : ${failure.message}',
      ),
      (_) {},
    );
  }

  void _onSetFilterChanged(
    AccountsSetFilterChanged event,
    Emitter<AccountsState> emit,
  ) {
    emit(state.copyWith(setFilterId: event.setId));
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

  Future<void> _onAccountEdited(
    AccountEdited event,
    Emitter<AccountsState> emit,
  ) async {
    final result = await _updateAccount(
      UpdateAccountParams(
        accountId: event.accountId,
        name: event.name,
        gameAccountId: event.gameAccountId,
      ),
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

  /// Critère de tri enregistré lors d'un lancement précédent. Une
  /// lecture impossible, ou l'absence de choix, laisse le critère
  /// courant (ordre de création au premier lancement).
  Future<AccountsSortOption> _readSavedSortOption() async {
    final result = await _getAccountsSortOption(const NoParams());
    return result.fold(
      (failure) {
        AppLogger.log(
          'WARNING',
          'Tri des comptes enregistré illisible : ${failure.message}',
        );
        return state.sortOption;
      },
      (saved) => saved ?? state.sortOption,
    );
  }

  /// Un calcul introuvable vaut une table vide, pas une erreur
  /// d'écran : voir la documentation de la classe.
  Future<Map<String, AccountExtras>> _fetchExtras() async {
    final result = await _getSecondaryAccountsExtras(const NoParams());
    return result.getOrElse(() => const <String, AccountExtras>{});
  }
}
