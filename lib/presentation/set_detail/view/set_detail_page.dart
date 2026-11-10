import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../domain/entities/card_set.dart';
import '../../rarity_scope/bloc/rarity_scope_card_group.dart';
import '../../rarity_scope/bloc/rarity_scope_cubit.dart';
import '../bloc/set_detail_bloc.dart';
import '../bloc/set_detail_event.dart';
import '../bloc/set_detail_state.dart';
import '../widgets/bulk_add_action.dart';
import '../widgets/bulk_add_confirmation_dialog.dart';
import '../widgets/card_element_logo.dart';
import '../widgets/card_grid_density.dart';
import '../widgets/card_grid_pager.dart';
import '../widgets/owner_filter_banner.dart';
import '../widgets/pinch_gesture_detector.dart';
import '../widgets/secondary_account_picker_dialog.dart';
import '../widgets/set_detail_filter_action.dart';
import '../widgets/set_detail_filter_sheet.dart';
import '../widgets/set_progress_summary.dart';

/// Écran de détail d'un set : ses cartes, filtrables par booster, par
/// rareté (multi-sélection), par possession (principal, secondaires
/// avec un sous-filtre par compte, manquantes) et par type (élément,
/// multi-sélection). Les filtres sont regroupés dans un panneau
/// ([SetDetailFilterSheet]) ouvert par le bouton de filtre de la barre
/// du haut, pour laisser toute la place à la grille. Un swipe
/// gauche/droite pour isoler les cartes losange ou non-losange (voir
/// [CardGridPager][../widgets/card_grid_pager.dart]). Ces volets
/// suivent le périmètre de raretés global ([RarityScopeCubit]) :
/// l'écran s'ouvre sur le volet du périmètre courant (Σ au milieu,
/// losange à gauche, étoile à droite), et un swipe change ce
/// périmètre pour toute l'app. Un pincement à
/// deux doigts change la densité de la grille : les doigts qui se
/// rapprochent passent de 3 à 5 colonnes (sans nom ni rareté sous les
/// cartes), les doigts qui s'écartent reviennent à 3.
///
/// Le tap simple bascule la possession pour le compte principal ; le
/// double-tap ouvre un popup pour choisir un compte secondaire ; le
/// bouton d'ajout, tout à droite de la barre du haut, ajoute d'un coup
/// toutes les cartes actuellement affichées au compte principal.
///
/// Quand [ownerFilterAccountId] est fourni (ouverture depuis le
/// détail des cartes en plus d'un compte secondaire), seules les
/// cartes possédées par ce compte sont affichées, avec un bandeau
/// ([OwnerFilterBanner]) qui le rappelle.
class SetDetailPage extends StatelessWidget {
  const SetDetailPage({
    required this.set,
    this.ownerFilterAccountId,
    this.ownerFilterAccountName,
    super.key,
  });

  /// Le set dont on affiche le détail. Passé tel quel depuis
  /// l'écran de liste plutôt que juste son id : son nom et ses
  /// boosters sont déjà connus, pas besoin d'attendre le
  /// chargement des cartes pour les afficher.
  final CardSet set;

  /// Compte dont on n'affiche que les cartes possédées. `null` = tout
  /// le set, sans restriction.
  final String? ownerFilterAccountId;

  /// Nom du compte de [ownerFilterAccountId], pour le bandeau.
  final String? ownerFilterAccountName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SetDetailBloc>()
        ..add(
          SetDetailStarted(
            set.id,
            ownerFilterAccountId: ownerFilterAccountId,
          ),
        ),
      child: _SetDetailView(
        set: set,
        ownerFilterAccountId: ownerFilterAccountId,
        ownerFilterAccountName: ownerFilterAccountName,
      ),
    );
  }
}

class _SetDetailView extends StatefulWidget {
  const _SetDetailView({
    required this.set,
    required this.ownerFilterAccountId,
    required this.ownerFilterAccountName,
  });

  final CardSet set;
  final String? ownerFilterAccountId;
  final String? ownerFilterAccountName;

  @override
  State<_SetDetailView> createState() => _SetDetailViewState();
}

class _SetDetailViewState extends State<_SetDetailView> {
  /// Volet actif de [CardGridPager], pour restreindre les puces de
  /// `RarityFilterBar` au groupe de rareté pertinent (voir
  /// `SetDetailState.availableRaritiesForGroup`) et pour savoir
  /// quelles cartes le bouton "+" doit ajouter (voir
  /// `SetDetailState.visibleCardsForGroup`) — sur ce volet losange,
  /// seules les cartes losange affichées sont concernées ; sur le
  /// volet étoile, seules les alternatives ; sur le volet du milieu,
  /// toutes les cartes affichées. Initialisé à partir du périmètre de
  /// raretés global ([RarityScopeCubit]), puis tenu à jour par le
  /// swipe ; ne vit pas dans [SetDetailBloc], qui n'a pas besoin de
  /// le connaître.
  late CardGroupFilter _activeGroup;

  /// Densité de la grille (3 ou 5 colonnes), changée par pincement.
  /// État purement local à l'affichage, comme [_activeGroup].
  CardGridDensity _density = CardGridDensity.comfortable;

  /// Vrai une fois les logos d'éléments lancés en préchargement (voir
  /// [didChangeDependencies]), pour ne le faire qu'une fois par écran.
  bool _elementLogosPrecached = false;

  @override
  void initState() {
    super.initState();
    _activeGroup = context.read<RarityScopeCubit>().state.cardGroup;
  }

  /// Précharge les logos d'éléments du filtre par type dès l'ouverture
  /// de l'écran, pour qu'ils soient prêts quand le panneau de filtres
  /// s'ouvre (voir [CardElementLogo.precacheAll]). Fait ici plutôt que
  /// dans [initState], où le préchargement ne peut pas encore lire le
  /// contexte.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_elementLogosPrecached) return;
    _elementLogosPrecached = true;
    CardElementLogo.precacheAll(context);
  }

  @override
  Widget build(BuildContext context) {
    final ownerName = widget.ownerFilterAccountName;
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
          actions: [
            if (state.status == SetDetailStatus.loaded) ...[
              SetDetailFilterAction(
                activeFilterCount: state.activeFilterCount,
                onPressed: () => _openFilterSheet(context),
              ),
              BulkAddAction(
                onPressed: state.visibleCardsForGroup(_activeGroup).isEmpty
                    ? null
                    : () => _onAddAllVisiblePressed(context, state),
              ),
            ],
          ],
          body: Column(
            children: [
              if (ownerName != null) OwnerFilterBanner(accountName: ownerName),
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
      isFiltered: state.hasContentFilters,
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
        onRetry: () => context.read<SetDetailBloc>().add(
              SetDetailStarted(
                widget.set.id,
                ownerFilterAccountId: widget.ownerFilterAccountId,
              ),
            ),
      );
    }

    // Doigts qui se rapprochent = on dézoome = plus de colonnes ;
    // doigts qui s'écartent = on zoome = moins de colonnes.
    return PinchGestureDetector(
      onPinchIn: () => _setDensity(CardGridDensity.compact),
      onPinchOut: () => _setDensity(CardGridDensity.comfortable),
      child: CardGridPager(
        cards: state.visibleCards,
        primaryOwnedCardIds: state.primaryOwnedCardIds,
        secondaryOwnedCardIds: state.secondaryOwnedCardIds,
        density: _density,
        initialGroup: _activeGroup,
        onTap: (cardId) =>
            context.read<SetDetailBloc>().add(CardOwnershipToggled(cardId)),
        onDoubleTap: (cardId) => _onCardDoubleTap(context, state, cardId),
        onPageChanged: (group) => _onPagerPageChanged(context, state, group),
      ),
    );
  }

  void _setDensity(CardGridDensity density) {
    if (density == _density) return;
    setState(() => _density = density);
  }

  /// Met à jour le volet actif et le périmètre de raretés global
  /// (l'accueil et les statistiques suivent), et retire de la
  /// sélection de rareté courante les puces devenues hors-sujet pour
  /// ce volet (ex: une rareté étoile sélectionnée en arrivant sur le
  /// volet losange) — sans quoi la grille se viderait
  /// silencieusement, sans qu'aucune puce cochée ne l'explique. Les
  /// puces encore valides pour le nouveau volet restent cochées.
  void _onPagerPageChanged(
    BuildContext context,
    SetDetailState state,
    CardGroupFilter group,
  ) {
    setState(() => _activeGroup = group);
    context.read<RarityScopeCubit>().select(group.rarityScope);
    final stillAvailable = state.availableRaritiesForGroup(group).toSet();
    final filteredSelection =
        state.selectedRarities.where(stillAvailable.contains).toSet();
    if (filteredSelection.length != state.selectedRarities.length) {
      context.read<SetDetailBloc>().add(RarityFilterChanged(filteredSelection));
    }
  }

  /// Ouvre le panneau de filtres sur le volet actif. Le Bloc de
  /// l'écran lui est transmis explicitement : une feuille modale ne
  /// voit pas les providers de la page.
  void _openFilterSheet(BuildContext context) {
    final bloc = context.read<SetDetailBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: SetDetailFilterSheet(
          set: widget.set,
          activeGroup: _activeGroup,
        ),
      ),
    );
  }

  /// Bouton "+" de la barre du haut : demande confirmation, puis
  /// ajoute au compte principal toutes les cartes actuellement
  /// affichées dans le volet actif — pas tout le set, juste ce que
  /// l'écran montre en ce moment (tous filtres inclus).
  Future<void> _onAddAllVisiblePressed(
    BuildContext context,
    SetDetailState state,
  ) async {
    final bloc = context.read<SetDetailBloc>();
    final visibleCards = state.visibleCardsForGroup(_activeGroup);
    if (visibleCards.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          BulkAddConfirmationDialog(cardCount: visibleCards.length),
    );
    if (confirmed != true) return;

    bloc.add(BulkCardsMarkedOwned(visibleCards.map((c) => c.id).toList()));
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