import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../domain/entities/card_set.dart';
import '../../set_detail/view/set_detail_page.dart';
import '../bloc/card_sets_bloc.dart';
import '../bloc/card_sets_event.dart';
import '../bloc/card_sets_state.dart';
import '../widgets/card_set_grid.dart';
import '../widgets/card_sets_empty_view.dart';
import '../widgets/sync_catalog_action.dart';

/// Écran d'accueil : liste des sets du référentiel TCG Pocket.
///
/// Point d'entrée de la feature catalogue. Un appui sur une tuile
/// ouvre [SetDetailPage] pour ce set.
class CardSetsPage extends StatelessWidget {
  const CardSetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CardSetsBloc>()..add(const CardSetsStarted()),
      child: const _CardSetsView(),
    );
  }
}

class _CardSetsView extends StatelessWidget {
  const _CardSetsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardSetsBloc, CardSetsState>(
      builder: (context, state) {
        return AppScaffold(
          title: 'Cartodex',
          actions: [
            SyncCatalogAction(
              isSyncing: state.status == CardSetsStatus.syncing,
              onPressed: () => context
                  .read<CardSetsBloc>()
                  .add(const CardSetsSyncRequested()),
            ),
          ],
          body: _buildBody(context, state),
        );
      },
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

    return CardSetGrid(
      sets: state.sets,
      onSetTap: (set) => _onSetTap(context, set),
    );
  }

  void _onSetTap(BuildContext context, CardSet set) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SetDetailPage(set: set)),
    );
  }
}