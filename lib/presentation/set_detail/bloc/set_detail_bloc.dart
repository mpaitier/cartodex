import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_cards_by_set.dart';
import '../../../domain/usecases/get_owned_cards_id.dart';
import '../../../domain/usecases/set_card_owned.dart';
import 'set_detail_event.dart';
import 'set_detail_state.dart';

/// ViewModel de l'écran de détail d'un set.
///
/// La possession est mise à jour de façon optimiste : l'UI change
/// immédiatement au tap, avant même la réponse du use case. En cas
/// d'échec de la persistance locale, l'état revient en arrière et
/// un message d'erreur est exposé — la vue l'affiche en SnackBar
/// plutôt que de remplacer toute la grille.
class SetDetailBloc extends Bloc<SetDetailEvent, SetDetailState> {
  SetDetailBloc({
    required GetCardsBySet getCardsBySet,
    required GetOwnedCardIds getOwnedCardIds,
    required SetCardOwned setCardOwned,
  })  : _getCardsBySet = getCardsBySet,
        _getOwnedCardIds = getOwnedCardIds,
        _setCardOwned = setCardOwned,
        super(const SetDetailState()) {
    on<SetDetailStarted>(_onStarted);
    on<CardOwnershipToggled>(_onCardOwnershipToggled);
    on<PackFilterChanged>(_onPackFilterChanged);
  }

  final GetCardsBySet _getCardsBySet;
  final GetOwnedCardIds _getOwnedCardIds;
  final SetCardOwned _setCardOwned;

  Future<void> _onStarted(
    SetDetailStarted event,
    Emitter<SetDetailState> emit,
  ) async {
    emit(state.copyWith(status: SetDetailStatus.loading));

    final cardsResult =
        await _getCardsBySet(GetCardsBySetParams(setId: event.setId));
    final ownedResult = await _getOwnedCardIds(const NoParams());

    final failure = cardsResult.fold((f) => f, (_) => null) ??
        ownedResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: SetDetailStatus.error,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SetDetailStatus.loaded,
        cards: cardsResult.getOrElse(() => const []),
        ownedCardIds: ownedResult.getOrElse(() => const <String>{}),
      ),
    );
  }

  Future<void> _onCardOwnershipToggled(
    CardOwnershipToggled event,
    Emitter<SetDetailState> emit,
  ) async {
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
      SetCardOwnedParams(cardId: event.cardId, owned: !wasOwned),
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