import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_accounts.dart';
import '../../../domain/usecases/get_cards_by_set.dart';
import '../../../domain/usecases/get_owned_cards_id.dart';
import '../../../domain/usecases/set_card_owned.dart';
import 'set_detail_event.dart';
import 'set_detail_state.dart';

/// ViewModel de l'écran de détail d'un set.
///
/// La possession est par compte : ce Bloc charge, à l'ouverture de
/// l'écran, tous les comptes existants et ce que chacun possède
/// dans ce set. Le tap simple bascule toujours la possession pour
/// le compte principal ; le double-tap ouvre un popup pour choisir
/// un compte secondaire précis (voir
/// [SecondaryAccountPickerDialog][../widgets/secondary_account_picker_dialog.dart]).
///
/// La possession se met à jour de façon optimiste, quel que soit
/// le compte visé : l'UI change immédiatement, avant même la
/// réponse du use case. En cas d'échec de la persistance locale,
/// l'état revient en arrière et un message d'erreur est exposé — la
/// vue l'affiche en SnackBar plutôt que de remplacer toute la
/// grille.
class SetDetailBloc extends Bloc<SetDetailEvent, SetDetailState> {
  SetDetailBloc({
    required GetCardsBySet getCardsBySet,
    required GetOwnedCardIds getOwnedCardIds,
    required SetCardOwned setCardOwned,
    required GetAccounts getAccounts,
  })  : _getCardsBySet = getCardsBySet,
        _getOwnedCardIds = getOwnedCardIds,
        _setCardOwned = setCardOwned,
        _getAccounts = getAccounts,
        super(const SetDetailState()) {
    on<SetDetailStarted>(_onStarted);
    on<CardOwnershipToggled>(_onCardOwnershipToggled);
    on<SecondaryOwnershipToggled>(_onSecondaryOwnershipToggled);
    on<PackFilterChanged>(_onPackFilterChanged);
    on<RarityFilterChanged>(_onRarityFilterChanged);
  }

  final GetCardsBySet _getCardsBySet;
  final GetOwnedCardIds _getOwnedCardIds;
  final SetCardOwned _setCardOwned;
  final GetAccounts _getAccounts;

  Future<void> _onStarted(
    SetDetailStarted event,
    Emitter<SetDetailState> emit,
  ) async {
    emit(state.copyWith(status: SetDetailStatus.loading));

    final cardsResult =
        await _getCardsBySet(GetCardsBySetParams(setId: event.setId));
    final accountsResult = await _getAccounts(const NoParams());

    final failure = cardsResult.fold((f) => f, (_) => null) ??
        accountsResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: SetDetailStatus.error,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    final cards = cardsResult.getOrElse(() => const []);
    final accounts = accountsResult.getOrElse(() => const []);

    // La possession de chaque compte est lue séparément : peu de
    // comptes en pratique, et ça garde le use case simple (un seul
    // compte à la fois, réutilisé tel quel pour le tap comme pour
    // le double-tap plus bas).
    final ownershipByAccountId = <String, Set<String>>{};
    for (final account in accounts) {
      final ownedResult = await _getOwnedCardIds(
        GetOwnedCardIdsParams(accountId: account.id),
      );
      final ownedFailure = ownedResult.fold((f) => f, (_) => null);
      if (ownedFailure != null) {
        emit(
          state.copyWith(
            status: SetDetailStatus.error,
            errorMessage: ownedFailure.message,
          ),
        );
        return;
      }
      ownershipByAccountId[account.id] =
          ownedResult.getOrElse(() => const <String>{});
    }

    emit(
      state.copyWith(
        status: SetDetailStatus.loaded,
        cards: cards,
        accounts: accounts,
        ownershipByAccountId: ownershipByAccountId,
      ),
    );
  }

  Future<void> _onCardOwnershipToggled(
    CardOwnershipToggled event,
    Emitter<SetDetailState> emit,
  ) async {
    final accountId = state.primaryAccountId;
    if (accountId == null) {
      emit(
        state.copyWith(
          errorMessage:
              'Crée un compte avant de marquer des cartes comme possédées.',
        ),
      );
      return;
    }
    await _toggleOwnershipForAccount(accountId, event.cardId, emit);
  }

  Future<void> _onSecondaryOwnershipToggled(
    SecondaryOwnershipToggled event,
    Emitter<SetDetailState> emit,
  ) async {
    await _toggleOwnershipForAccount(event.accountId, event.cardId, emit);
  }

  Future<void> _toggleOwnershipForAccount(
    String accountId,
    String cardId,
    Emitter<SetDetailState> emit,
  ) async {
    final previousMap = state.ownershipByAccountId;
    final currentIds = previousMap[accountId] ?? const <String>{};
    final wasOwned = currentIds.contains(cardId);
    final optimisticIds = Set<String>.from(currentIds);
    if (wasOwned) {
      optimisticIds.remove(cardId);
    } else {
      optimisticIds.add(cardId);
    }
    final optimisticMap = Map<String, Set<String>>.from(previousMap)
      ..[accountId] = optimisticIds;
    emit(state.copyWith(ownershipByAccountId: optimisticMap));

    final result = await _setCardOwned(
      SetCardOwnedParams(
        cardId: cardId,
        accountId: accountId,
        owned: !wasOwned,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          ownershipByAccountId: previousMap,
          errorMessage: failure.message,
        ),
      ),
      (_) {},
    );
  }

  Future<void> _onPackFilterChanged(
    PackFilterChanged event,
    Emitter<SetDetailState> emit,
  ) async {
    emit(state.copyWith(selectedPack: event.pack));
  }

  Future<void> _onRarityFilterChanged(
    RarityFilterChanged event,
    Emitter<SetDetailState> emit,
  ) async {
    emit(state.copyWith(selectedRarities: event.rarities));
  }
}