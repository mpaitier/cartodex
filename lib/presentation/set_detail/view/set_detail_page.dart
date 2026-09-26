import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../domain/entities/card_set.dart';
import '../bloc/set_detail_bloc.dart';
import '../bloc/set_detail_event.dart';
import '../bloc/set_detail_state.dart';
import '../widgets/card_grid_pager.dart';
import '../widgets/pack_filter_bar.dart';
import '../widgets/rarity_filter_bar.dart';
import '../widgets/secondary_account_picker_dialog.dart';
import '../widgets/set_progress_summary.dart';

/// Écran de détail d'un set : ses cartes, filtrables par booster et
/// par rareté (multi-sélection), avec un swipe gauche/droite pour
/// isoler les cartes losange ou non-losange (voir
/// [CardGridPager][../widgets/card_grid_pager.dart]). Le tap simple
/// bascule la possession pour le compte principal ; le double-tap
/// ouvre un popup pour choisir un compte secondaire.
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

class _SetDetailView extends StatefulWidget {
  const _SetDetailView({required this.set});

  final CardSet set;

  @override
  State<_SetDetailView> createState() => _SetDetailViewState();
}

class _SetDetailViewState extends State<_SetDetailView> {
  /// Volet actif de [CardGridPager], pour restreindre les puces de
  /// `RarityFilterBar` au groupe de rareté pertinent (voir
  /// `SetDetailState.availableRaritiesForGroup`). État purement
  /// local à l'affichage, sur le même principe que
  /// `SetProgressSummary._includeSecondary` : ne vaut pas la peine de
  /// vivre dans le Bloc. Volet du milieu par défaut, comme
  /// `CardGridPager` (`PageController(initialPage: 1)`).
  CardGroupFilter _activeGroup = CardGroupFilter.all;

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
          title: widget.set.name,
          titleWidget: _titleWidget(state),
          body: Column(
            children: [
              PackFilterBar(
                packs: widget.set.packs,
                selectedPack: state.selectedPack,
                onPackSelected: (pack) => context
                    .read<SetDetailBloc>()
                    .add(PackFilterChanged(pack)),
              ),
              RarityFilterBar(
                availableRarities: state.availableRaritiesForGroup(_activeGroup),
                selectedRarities: state.selectedRarities,
                onSelectionChanged: (rarities) => context
                    .read<SetDetailBloc>()
                    .add(RarityFilterChanged(rarities)),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  /// `null` tant que les cartes ne sont pas chargées, pour laisser
  /// `AppScaffold` retomber sur le simple nom du set le temps du
  /// chargement plutôt que d'afficher "0/0" partout.
  Widget? _titleWidget(SetDetailState state) {
    if (state.cards.isEmpty) return null;
    return SetProgressSummary(
      setName: widget.set.name,
      baseOwnedPrimary: state.baseOwned,
      baseOwnedAllAccounts: state.baseOwnedAllAccounts,
      baseTotal: state.baseTotal,
      alternativeOwnedPrimary: state.alternativeOwned,
      alternativeOwnedAllAccounts: state.alternativeOwnedAllAccounts,
      alternativeTotal: state.alternativeTotal,
    );
  }

  Widget _buildBody(BuildContext context, SetDetailState state) {
    if (state.status == SetDetailStatus.initial ||
        state.status == SetDetailStatus.loading) {
      return const AppLoadingIndicator(message: 'Chargement des cartes…');
    }

    if (state.status == SetDetailStatus.error && state.cards.isEmpty) {
      return AppErrorView(
        message: state.errorMessage ?? 'Une erreur est survenue.',
        onRetry: () => context
            .read<SetDetailBloc>()
            .add(SetDetailStarted(widget.set.id)),
      );
    }

    return CardGridPager(
      cards: state.visibleCards,
      primaryOwnedCardIds: state.primaryOwnedCardIds,
      secondaryOwnedCardIds: state.secondaryOwnedCardIds,
      onTap: (cardId) =>
          context.read<SetDetailBloc>().add(CardOwnershipToggled(cardId)),
      onDoubleTap: (cardId) => _onCardDoubleTap(context, state, cardId),
      onPageChanged: (group) => _onPagerPageChanged(context, state, group),
    );
  }

  /// Met à jour le volet actif, et retire de la sélection de rareté
  /// courante les puces devenues hors-sujet pour ce volet (ex: une
  /// rareté étoile sélectionnée en arrivant sur le volet losange) —
  /// sans quoi la grille se viderait silencieusement, sans qu'aucune
  /// puce cochée ne l'explique. Les puces encore valides pour le
  /// nouveau volet restent cochées.
  void _onPagerPageChanged(
    BuildContext context,
    SetDetailState state,
    CardGroupFilter group,
  ) {
    setState(() => _activeGroup = group);
    final stillAvailable = state.availableRaritiesForGroup(group).toSet();
    final filteredSelection =
        state.selectedRarities.where(stillAvailable.contains).toSet();
    if (filteredSelection.length != state.selectedRarities.length) {
      context.read<SetDetailBloc>().add(RarityFilterChanged(filteredSelection));
    }
  }

  void _onCardDoubleTap(
    BuildContext context,
    SetDetailState state,
    String cardId,
  ) {
    final bloc = context.read<SetDetailBloc>();
    final ownedByAccountId = <String>{
      for (final account in state.secondaryAccounts)
        if ((state.ownershipByAccountId[account.id] ?? const {})
            .contains(cardId))
          account.id,
    };
    showDialog<void>(
      context: context,
      builder: (_) => SecondaryAccountPickerDialog(
        accounts: state.secondaryAccounts,
        ownedByAccountId: ownedByAccountId,
        onAccountSelected: (accountId) => bloc.add(
          SecondaryOwnershipToggled(cardId: cardId, accountId: accountId),
        ),
      ),
    );
  }
}