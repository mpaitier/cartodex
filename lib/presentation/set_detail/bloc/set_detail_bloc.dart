import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_accounts.dart';
import '../../../domain/usecases/get_cards_by_set.dart';
import '../../../domain/usecases/get_owned_cards_id.dart';
import '../../../domain/usecases/set_card_owned.dart';
import 'set_detail_event.dart';
import 'set_detail_state.dart';

/// ViewModel de l'écran de détail d'un set.
///
/// La possession est scopée par compte : ce Bloc résout le compte
/// principal à l'ouverture de l'écran et l'utilise comme compte
/// actif pour la lecture et l'écriture de la possession — le tap
/// simple agit toujours sur le principal, en attendant le
/// double-tap (choix d'un compte secondaire, prochaine étape).
///
/// La possession se met à jour de façon optimiste : l'UI change
/// immédiatement au tap, avant même la réponse du use case. En cas
/// d'échec de la persistance locale, l'état revient en arrière et
/// un message d'erreur est exposé — la vue l'affiche en SnackBar
/// plutôt que de remplacer toute la grille.
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
    on<PackFilterChanged>(_onPackFilterChanged);
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
    Account? primaryAccount;
    for (final account in accounts) {
      if (account.isPrimary) {
        primaryAccount = account;
        break;
      }
    }

    if (primaryAccount == null) {
      // Aucun compte encore créé : les cartes restent consultables,
      // seule la possession est indisponible pour l'instant.
      emit(
        state.copyWith(
          status: SetDetailStatus.loaded,
          cards: cards,
          ownedCardIds: const <String>{},
          activeAccountId: null,
        ),
      );
      return;
    }

    final ownedResult = await _getOwnedCardIds(
      GetOwnedCardIdsParams(accountId: primaryAccount.id),
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

    emit(
      state.copyWith(
        status: SetDetailStatus.loaded,
        cards: cards,
        ownedCardIds: ownedResult.getOrElse(() => const <String>{}),
        activeAccountId: primaryAccount.id,
      ),
    );
  }

  Future<void> _onCardOwnershipToggled(
    CardOwnershipToggled event,
    Emitter<SetDetailState> emit,
  ) async {
    final accountId = state.activeAccountId;
    if (accountId == null) {
      emit(
        state.copyWith(
          errorMessage:
              'Crée un compte avant de marquer des cartes comme possédées.',
        ),
      );
      return;
    }

    final previousIds = state.ownedCardIds;
    final wasOwned = previousIds.contains(event.cardId);
    final optimisticIds = Set<String>.from(previousIds);
    if (wasOwned) {
      optimisticIds.remove(event.cardId);
    } else {
      optimisticIds.add(event.cardId);
    }
    emit(state.copyWith(ownedCardIds: optimisticIds));

    final result = await _setCardOwned(
      SetCardOwnedParams(
        cardId: event.cardId,
        accountId: accountId,
        owned: !wasOwned,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          ownedCardIds: previousIds,
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
}