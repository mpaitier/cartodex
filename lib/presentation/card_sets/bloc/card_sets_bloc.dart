import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/set_progress.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_cards.dart';
import '../../../domain/usecases/get_sets_progress.dart';
import '../../../domain/usecases/sync_card_catalog.dart';
import 'card_sets_event.dart';
import 'card_sets_state.dart';

/// ViewModel de l'écran de liste des sets.
///
/// Sépare volontairement le chargement local ([CardSetsStarted]) de
/// la synchronisation distante ([CardSetsSyncRequested]) : ouvrir
/// l'écran ne doit jamais dépendre du réseau.
///
/// Charge aussi la progression du compte principal pour chaque set
/// (voir [GetSetsProgress]). Un échec de ce calcul ne fait jamais
/// tomber l'écran : les sets s'affichent, simplement sans bordure de
/// progression.
class CardSetsBloc extends Bloc<CardSetsEvent, CardSetsState> {
  CardSetsBloc({
    required GetCardSets getCardSets,
    required SyncCardCatalog syncCardCatalog,
    required GetSetsProgress getSetsProgress,
  })  : _getCardSets = getCardSets,
        _syncCardCatalog = syncCardCatalog,
        _getSetsProgress = getSetsProgress,
        super(const CardSetsState()) {
    on<CardSetsStarted>(_onStarted);
    on<CardSetsSyncRequested>(_onSyncRequested);
    on<SeriesFilterChanged>(_onSeriesFilterChanged);
    on<CardSetsProgressRefreshRequested>(_onProgressRefreshRequested);
  }

  final GetCardSets _getCardSets;
  final SyncCardCatalog _syncCardCatalog;
  final GetSetsProgress _getSetsProgress;

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
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: CardSetsStatus.error,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    final sets = result.getOrElse(() => const []);
    final progress = await _fetchProgress();

    var next = state.copyWith(
      status: CardSetsStatus.loaded,
      sets: sets,
      progressBySetId: progress,
    );
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
  }

  /// Une progression introuvable vaut une table vide, pas une
  /// erreur d'écran : voir la documentation de la classe.
  Future<Map<String, SetProgress>> _fetchProgress() async {
    final result = await _getSetsProgress(const NoParams());
    return result.getOrElse(() => const <String, SetProgress>{});
  }

  Future<void> _onProgressRefreshRequested(
    CardSetsProgressRefreshRequested event,
    Emitter<CardSetsState> emit,
  ) async {
    // Tant que les sets ne sont pas chargés (ou en erreur), rien à
    // rafraîchir : le chargement initial calcule déjà la progression.
    if (state.status != CardSetsStatus.loaded) return;
    final progress = await _fetchProgress();
    emit(state.copyWith(progressBySetId: progress));
  }

  Future<void> _onSeriesFilterChanged(
    SeriesFilterChanged event,
    Emitter<CardSetsState> emit,
  ) async {
    emit(state.copyWith(selectedSeriesKey: event.seriesKey));
  }
}