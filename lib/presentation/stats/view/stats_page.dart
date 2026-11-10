import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../domain/entities/card_set.dart';
import '../../../domain/entities/rarity_scope.dart';
import '../../../l10n/l10n.dart';
import '../../rarity_scope/bloc/rarity_scope_cubit.dart';
import '../../set_detail/view/set_detail_page.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_event.dart';
import '../bloc/stats_state.dart';
import '../widgets/overall_progress_card.dart';
import '../widgets/priority_boosters_section.dart';
import '../widgets/rarity_scope_action.dart';
import '../widgets/series_progress_list.dart';

/// Écran de statistiques : taux de complétion global, détail par
/// série, et boosters à ouvrir en priorité.
///
/// Les chiffres sont ceux du compte principal (violet), prolongés en
/// jaune par ce que les comptes secondaires possèdent en plus — voir
/// [StatsBloc]. Le bouton de la top bar ([RarityScopeAction]) restreint
/// le tout à une famille de raretés : Σ (toutes), losange, étoile. Ce
/// périmètre est celui de toute l'app ([RarityScopeCubit]) : le
/// changer ici le change aussi sur l'accueil, et inversement.
/// La section des boosters prioritaires a en plus son propre
/// sélecteur de série ([PriorityBoostersSection]). Un appui sur un set
/// ou un booster de cette section ouvre le détail du set
/// ([SetDetailPage]), sans filtre ; les statistiques sont recalculées
/// au retour.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<StatsBloc>()
        ..add(
          StatsStarted(
            rarityScope: context.read<RarityScopeCubit>().state,
          ),
        ),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    // Le périmètre global peut changer depuis cet écran (bouton de la
    // top bar) ou depuis le détail d'un set ouvert par-dessus (swipe
    // entre volets) : dans les deux cas, il est relayé au Bloc.
    return BlocListener<RarityScopeCubit, RarityScope>(
      listener: (context, scope) =>
          context.read<StatsBloc>().add(StatsRarityScopeChanged(scope)),
      child: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          return AppScaffold(
            title: context.l10n.statsTitle,
            actions: [
              BlocBuilder<RarityScopeCubit, RarityScope>(
                builder: (context, scope) => RarityScopeAction(
                  scope: scope,
                  onPressed: () => context.read<RarityScopeCubit>().cycle(),
                ),
              ),
            ],
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StatsState state) {
    final l10n = context.l10n;
    if (state.status == StatsStatus.initial ||
        state.status == StatsStatus.loading) {
      return AppLoadingIndicator(message: l10n.statsLoading);
    }

    if (state.status == StatsStatus.noAccount) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.statsNoAccount,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.status == StatsStatus.error) {
      return AppErrorView(
        message: state.errorMessage ?? l10n.genericError,
        onRetry: () => context.read<StatsBloc>().add(
              StatsStarted(
                rarityScope: context.read<RarityScopeCubit>().state,
              ),
            ),
      );
    }

    final stats = state.stats;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OverallProgressCard(progress: stats.overall),
        const SizedBox(height: 24),
        Text(
          l10n.statsBySeries,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SeriesProgressList(seriesStats: stats.seriesStats),
        const SizedBox(height: 24),
        PriorityBoostersSection(
          series: state.boosterSeries,
          selectedSeriesKey: state.effectiveBoosterSeriesKey,
          setProgress: state.priorityBoosters,
          onSeriesSelected: (seriesKey) => context
              .read<StatsBloc>()
              .add(StatsBoosterSeriesSelected(seriesKey)),
          onSetTap: (set) => _openSet(context, set),
        ),
      ],
    );
  }

  /// Ouvre le détail de [set], puis demande au Bloc de recalculer une
  /// fois revenu : des cartes ont pu y être cochées. Le Bloc est lu
  /// avant l'attente, pour ne pas toucher au `context` après la
  /// navigation.
  Future<void> _openSet(BuildContext context, CardSet set) async {
    final bloc = context.read<StatsBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SetDetailPage(set: set)),
    );
    if (!bloc.isClosed) {
      bloc.add(const StatsRefreshRequested());
    }
  }
}