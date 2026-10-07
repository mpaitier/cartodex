import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/card_rarities.dart';
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
/// [SecondaryAccountPickerDialog][../widgets/secondary_account_picker_dialog.dart]) ;
/// le bouton "+" (après confirmation) en bascule plusieurs à la fois
/// pour le compte principal (voir [BulkCardsMarkedOwned]).
///
/// L'écran peut être ouvert restreint aux cartes d'un compte (voir
/// `SetDetailStarted.ownerFilterAccountId`) : la restriction est
/// mémorisée dans l'état à l'ouverture, et appliquée par
/// `SetDetailState.visibleCards`.
///
/// Les filtres (booster, rareté, possession et son sous-filtre par
/// compte secondaire) vivent dans l'état et sont appliqués par
/// `SetDetailState.visibleCards`. Un changement de filtre de
/// possession retire de la sélection de rareté les puces qui ne
/// correspondent plus à aucune carte, sans quoi la grille se viderait
/// sans qu'aucune puce cochée ne l'explique.
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
    on<BulkCardsMarkedOwned>(_onBulkCardsMarkedOwned);
    on<PackFilterChanged>(_onPackFilterChanged);
    on<RarityFilterChanged>(_onRarityFilterChanged);
    on<OwnershipFilterChanged>(_onOwnershipFilterChanged);
    on<SecondaryAccountFilterChanged>(_onSecondaryAccountFilterChanged);
  }

  final GetCardsBySet _getCardsBySet;
  final GetOwnedCardIds _getOwnedCardIds;
  final SetCardOwned _setCardOwned;
  final GetAccounts _getAccounts;

  Future<void> _onStarted(
    SetDetailStarted event,
    Emitter<SetDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SetDetailStatus.loading,
        ownerFilterAccountId: event.ownerFilterAccountId,
      ),
    );

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

  /// Marque [event.cardIds] comme possédées par le compte principal,
  /// en une fois. Tout ou rien : au premier échec, l'état entier
  /// revient à ce qu'il était avant l'appui sur "+" — plus simple à
  /// comprendre pour l'utilisateur qu'un ajout partiel silencieux.
  /// Ne touche pas aux identifiants déjà possédés (pas d'écriture
  /// inutile en base).
  Future<void> _onBulkCardsMarkedOwned(
    BulkCardsMarkedOwned event,
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

    final previousMap = state.ownershipByAccountId;
    final currentIds = previousMap[accountId] ?? const <String>{};
    final idsToAdd =
        event.cardIds.where((id) => !currentIds.contains(id)).toList();
    if (idsToAdd.isEmpty) return;

    final optimisticMap = Map<String, Set<String>>.from(previousMap)
      ..[accountId] = {...currentIds, ...idsToAdd};
    emit(state.copyWith(ownershipByAccountId: optimisticMap));

    for (final cardId in idsToAdd) {
      final result = await _setCardOwned(
        SetCardOwnedParams(cardId: cardId, accountId: accountId, owned: true),
      );
      final failure = result.fold((f) => f, (_) => null);
      if (failure != null) {
        emit(
          state.copyWith(
            ownershipByAccountId: previousMap,
            errorMessage: failure.message,
          ),
        );
        return;
      }
    }
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

  /// Change le filtre de possession et remet le sous-filtre par
  /// compte à "tous" : un compte choisi pour un filtre n'a pas de
  /// sens pour un autre.
  Future<void> _onOwnershipFilterChanged(
    OwnershipFilterChanged event,
    Emitter<SetDetailState> emit,
  ) async {
    final next = state.copyWith(
      ownershipFilter: event.filter,
      secondaryFilterAccountId: null,
    );
    emit(_withValidRarities(next));
  }

  Future<void> _onSecondaryAccountFilterChanged(
    SecondaryAccountFilterChanged event,
    Emitter<SetDetailState> emit,
  ) async {
    final next = state.copyWith(secondaryFilterAccountId: event.accountId);
    emit(_withValidRarities(next));
  }

  /// Retire de [next] les raretés cochées qui ne correspondent plus
  /// à aucune carte après un changement de filtre de possession. On
  /// compare au volet "tout" : une rareté cochée l'a été sur un volet
  /// où elle était proposée, donc présente dans le volet "tout"
  /// exactement quand elle l'est dans son propre volet.
  SetDetailState _withValidRarities(SetDetailState next) {
    final available =
        next.availableRaritiesForGroup(CardGroupFilter.all).toSet();
    final kept = next.selectedRarities.where(available.contains).toSet();
    if (kept.length == next.selectedRarities.length) return next;
    return next.copyWith(selectedRarities: kept);
  }
}