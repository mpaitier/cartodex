import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../domain/entities/card_set.dart';
import '../../accounts/view/accounts_page.dart';
import '../../set_detail/view/set_detail_page.dart';
import '../../stats/view/stats_page.dart';
import '../../sync/bloc/sync_bloc.dart';
import '../../sync/bloc/sync_state.dart';
import '../bloc/card_sets_bloc.dart';
import '../bloc/card_sets_event.dart';
import '../bloc/card_sets_state.dart';
import '../widgets/card_set_grid.dart';
import '../widgets/card_sets_empty_view.dart';
import '../widgets/series_filter_bar.dart';
import '../widgets/sync_catalog_action.dart';
import '../widgets/sync_firebase_action.dart';

/// Écran d'accueil : liste des sets du référentiel TCG Pocket.
///
/// Point d'entrée de la feature catalogue, de la gestion de comptes
/// et des statistiques. AppBar : à gauche, statistiques et comptes
/// Pokémon ; à droite, synchronisation du référentiel de cartes et
/// synchronisation avec le compte applicatif (Firebase — voir
/// `SyncFirebaseAction`, `SyncBloc`, fourni ici avec le même cycle
/// de vie que l'écran). Un appui sur une tuile ouvre [SetDetailPage]
/// pour ce set ; le menu flottant du bas ([SeriesFilterBar]) filtre
/// la grille par série.
///
/// Chaque tuile montre la progression du compte principal (voir
/// `SetProgressBorder`). Elle est recalculée au retour du détail d'un
/// set ou de la gestion des comptes, et après une synchronisation
/// cloud réussie, puisque la possession a pu y changer.
class CardSetsPage extends StatelessWidget {
  const CardSetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<CardSetsBloc>()..add(const CardSetsStarted()),
        ),
        BlocProvider(create: (_) => sl<SyncBloc>()),
      ],
      child: const _CardSetsView(),
    );
  }
}

class _CardSetsView extends StatelessWidget {
  const _CardSetsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncBloc, SyncState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == SyncStatus.success,
      listener: (context, _) => context
          .read<CardSetsBloc>()
          .add(const CardSetsProgressRefreshRequested()),
      child: BlocBuilder<CardSetsBloc, CardSetsState>(
        builder: (context, state) {
          return AppScaffold(
            title: 'Cartodex',
            leadingActions: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const StatsPage()),
                ),
                icon: const Icon(Icons.bar_chart),
                tooltip: 'Statistiques',
              ),
              IconButton(
                onPressed: () => _openAndRefresh(context, const AccountsPage()),
                icon: const Icon(Icons.people_alt_outlined),
                tooltip: 'Comptes',
              ),
            ],
            actions: [
              SyncCatalogAction(
                isSyncing: state.status == CardSetsStatus.syncing,
                onPressed: () => context
                    .read<CardSetsBloc>()
                    .add(const CardSetsSyncRequested()),
              ),
              const SyncFirebaseAction(),
            ],
            body: Stack(
              children: [
                _buildBody(context, state),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SeriesFilterBar(
                    tabs: state.seriesTabs,
                    selectedKey: state.selectedSeriesKey,
                    onSelected: (key) => context
                        .read<CardSetsBloc>()
                        .add(SeriesFilterChanged(key)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CardSetsState state) {
    final isFirstLoad = state.status == CardSetsStatus.initial ||
        state.status == CardSetsStatus.loading;
    final isFirstSync =
        state.status == CardSetsStatus.syncing && state.sets.isEmpty;
    if (isFirstLoad || isFirstSync) {
      return const AppLoadingIndicator(
        message: 'Chargement du référentiel…',
      );
    }

    if (state.status == CardSetsStatus.error) {
      return AppErrorView(
        message: state.errorMessage ?? 'Une erreur est survenue.',
        onRetry: () =>
            context.read<CardSetsBloc>().add(const CardSetsStarted()),
      );
    }

    if (state.sets.isEmpty) {
      return CardSetsEmptyView(
        onSync: () =>
            context.read<CardSetsBloc>().add(const CardSetsSyncRequested()),
      );
    }

    // Marge basse pour que les dernières tuiles ne se retrouvent pas
    // sous le menu flottant.
    return Padding(
      padding: const EdgeInsets.only(bottom: 72),
      child: CardSetGrid(
        sets: state.visibleSets,
        progressBySetId: state.progressBySetId,
        onSetTap: (set) => _onSetTap(context, set),
      ),
    );
  }

  void _onSetTap(BuildContext context, CardSet set) {
    _openAndRefresh(context, SetDetailPage(set: set));
  }

  /// Ouvre [page], puis demande au Bloc de recalculer la progression
  /// des tuiles une fois revenu sur l'accueil : la possession (ou le
  /// compte principal) a pu changer entre-temps. Le Bloc est lu avant
  /// l'attente, pour ne pas toucher au `context` après la navigation.
  Future<void> _openAndRefresh(BuildContext context, Widget page) async {
    final bloc = context.read<CardSetsBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (!bloc.isClosed) {
      bloc.add(const CardSetsProgressRefreshRequested());
    }
  }
}