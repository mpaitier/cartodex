import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../domain/entities/card_set.dart';
import '../bloc/set_detail_bloc.dart';
import '../bloc/set_detail_event.dart';
import '../bloc/set_detail_state.dart';
import '../widgets/card_grid.dart';
import '../widgets/pack_filter_bar.dart';

/// Écran de détail d'un set : ses cartes, filtrables par booster,
/// avec bascule de possession au tap sur une carte.
class SetDetailPage extends StatelessWidget {
  const SetDetailPage({required this.set, super.key});

  /// Le set dont on affiche le détail. Passé tel quel depuis
  /// l'écran de liste plutôt que juste son id : son nom et ses
  /// boosters sont déjà connus, pas besoin d'attendre le
  /// chargement des cartes pour les afficher.
  final CardSet set;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SetDetailBloc>()..add(SetDetailStarted(set.id)),
      child: _SetDetailView(set: set),
    );
  }
}

class _SetDetailView extends StatelessWidget {
  const _SetDetailView({required this.set});

  final CardSet set;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SetDetailBloc, SetDetailState>(
      listener: (context, state) {
        // Un échec de bascule de possession ne remplace pas toute
        // la grille (voir _buildBody) : il est signalé ici, sans
        // perturber le reste de l'écran.
        if (state.status == SetDetailStatus.loaded &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: _title(state),
          body: Column(
            children: [
              PackFilterBar(
                packs: set.packs,
                selectedPack: state.selectedPack,
                onPackSelected: (pack) => context
                    .read<SetDetailBloc>()
                    .add(PackFilterChanged(pack)),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  /// "<nom du set> - X acquis / total", une fois les cartes
  /// chargées ; juste le nom du set avant ça, pour ne pas afficher
  /// "0 acquis / 0" le temps du chargement.
  String _title(SetDetailState state) {
    if (state.cards.isEmpty) return set.name;
    final owned =
        state.cards.where((card) => state.ownedCardIds.contains(card.id));
    return '${set.name} - ${owned.length} acquis / ${state.cards.length}';
  }

  Widget _buildBody(BuildContext context, SetDetailState state) {
    if (state.status == SetDetailStatus.initial ||
        state.status == SetDetailStatus.loading) {
      return const AppLoadingIndicator(message: 'Chargement des cartes…');
    }

    if (state.status == SetDetailStatus.error && state.cards.isEmpty) {
      return AppErrorView(
        message: state.errorMessage ?? 'Une erreur est survenue.',
        onRetry: () =>
            context.read<SetDetailBloc>().add(SetDetailStarted(set.id)),
      );
    }

    return CardGrid(
      cards: state.visibleCards,
      ownedCardIds: state.ownedCardIds,
      onToggleOwned: (cardId) =>
          context.read<SetDetailBloc>().add(CardOwnershipToggled(cardId)),
    );
  }
}