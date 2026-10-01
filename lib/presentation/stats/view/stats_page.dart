import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_event.dart';
import '../bloc/stats_state.dart';
import '../widgets/overall_progress_card.dart';
import '../widgets/priority_boosters_list.dart';
import '../widgets/rarity_scope_action.dart';
import '../widgets/series_progress_list.dart';

/// Écran de statistiques : taux de complétion global, détail par
/// série, et boosters à ouvrir en priorité.
///
/// Les chiffres sont ceux du compte principal (violet), prolongés en
/// jaune par ce que les comptes secondaires possèdent en plus — voir
/// [StatsBloc]. Le bouton de la top bar ([RarityScopeAction]) restreint
/// le tout à une famille de raretés : rond (toutes), losange, étoile.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StatsBloc>()..add(const StatsStarted()),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        return AppScaffold(
          title: 'Statistiques',
          actions: [
            RarityScopeAction(
              scope: state.rarityScope,
              onPressed: () => context
                  .read<StatsBloc>()
                  .add(StatsRarityScopeChanged(state.rarityScope.next)),
            ),
          ],
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StatsState state) {
    if (state.status == StatsStatus.initial ||
        state.status == StatsStatus.loading) {
      return const AppLoadingIndicator(message: 'Calcul des statistiques…');
    }

    if (state.status == StatsStatus.noAccount) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Crée un compte pour voir tes statistiques.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.status == StatsStatus.error) {
      return AppErrorView(
        message: state.errorMessage ?? 'Une erreur est survenue.',
        onRetry: () => context.read<StatsBloc>().add(const StatsStarted()),
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
        Text('Par série', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SeriesProgressList(seriesStats: stats.seriesStats),
        const SizedBox(height: 24),
        Text(
          'Boosters à ouvrir en priorité',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        PriorityBoostersList(setProgress: stats.priorityBoosterProgress),
      ],
    );
  }
}