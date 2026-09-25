import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_cards.dart';
import '../../../domain/usecases/sync_card_catalog.dart';
import 'card_sets_event.dart';
import 'card_sets_state.dart';

/// ViewModel de l'écran de liste des sets.
///
/// Sépare volontairement le chargement local ([CardSetsStarted]) de
/// la synchronisation distante ([CardSetsSyncRequested]) : ouvrir
/// l'écran ne doit jamais dépendre du réseau.
class CardSetsBloc extends Bloc<CardSetsEvent, CardSetsState> {
  CardSetsBloc({
    required GetCardSets getCardSets,
    required SyncCardCatalog syncCardCatalog,
  })  : _getCardSets = getCardSets,
        _syncCardCatalog = syncCardCatalog,
        super(const CardSetsState()) {
    on<CardSetsStarted>(_onStarted);
    on<CardSetsSyncRequested>(_onSyncRequested);
    on<SeriesFilterChanged>(_onSeriesFilterChanged);
  }

  final GetCardSets _getCardSets;
  final SyncCardCatalog _syncCardCatalog;

  Future<void> _onStarted(
    CardSetsStarted event,
    Emitter<CardSetsState> emit,
  ) async {
    emit(state.copyWith(status: CardSetsStatus.loading));
    await _loadSets(emit);
  }

  Future<void> _onSyncRequested(
    CardSetsSyncRequested event,
    Emitter<CardSetsState> emit,
  ) async {
    emit(state.copyWith(status: CardSetsStatus.syncing));
    final result = await _syncCardCatalog(const NoParams());
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: CardSetsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => _loadSets(emit),
    );
  }

  Future<void> _loadSets(Emitter<CardSetsState> emit) async {
    final result = await _getCardSets(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CardSetsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (sets) {
        var next = state.copyWith(status: CardSetsStatus.loaded, sets: sets);
        // Par défaut (ou si la série choisie a disparu, ex: après une
        // resynchronisation), on retombe sur la plus récente : le
        // premier onglet, seriesTabs plaçant toujours les séries
        // lettrées les plus récentes en tête.
        final tabs = next.seriesTabs;
        final hasValidSelection =
            tabs.any((tab) => tab.key == next.selectedSeriesKey);
        if (!hasValidSelection && tabs.isNotEmpty) {
          next = next.copyWith(selectedSeriesKey: tabs.first.key);
        }
        emit(next);
      },
    );
  }

  Future<void> _onSeriesFilterChanged(
    SeriesFilterChanged event,
    Emitter<CardSetsState> emit,
  ) async {
    emit(state.copyWith(selectedSeriesKey: event.seriesKey));
  }
}