import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../domain/entities/card_set.dart';
import '../bloc/ownership_filter.dart';
import '../bloc/set_detail_bloc.dart';
import '../bloc/set_detail_event.dart';
import '../bloc/set_detail_state.dart';
import 'element_filter_bar.dart';
import 'filter_sheet_section.dart';
import 'ownership_filter_bar.dart';
import 'pack_filter_bar.dart';
import 'rarity_filter_bar.dart';
import 'secondary_account_filter_bar.dart';

/// Panneau de filtres du détail d'un set, ouvert depuis le bouton de
/// la barre du haut (`SetDetailFilterAction`).
///
/// Regroupe tous les filtres de la grille, rubrique par rubrique
/// ([FilterSheetSection]) : booster, rareté, possession (avec le
/// sous-filtre par compte secondaire) et type ([ElementFilterBar]).
/// Une rubrique sans choix à proposer est masquée. "Réinitialiser"
/// remet tout à zéro ([FiltersCleared]).
///
/// Suit l'état de [SetDetailBloc] en direct : la grille derrière le
/// panneau se met à jour à chaque puce touchée. L'appelant doit donc
/// fournir le Bloc de l'écran au panneau (`BlocProvider.value`), une
/// feuille modale ne voyant pas les providers de la page.
///
/// Les raretés proposées dépendent du volet ouvert au moment de
/// l'ouverture ([activeGroup]) ; il ne peut pas changer tant que le
/// panneau est affiché.
class SetDetailFilterSheet extends StatelessWidget {
  const SetDetailFilterSheet({
    required this.set,
    required this.activeGroup,
    super.key,
  });

  final CardSet set;
  final CardGroupFilter activeGroup;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetDetailBloc, SetDetailState>(
      builder: (context, state) {
        final bloc = context.read<SetDetailBloc>();
        final hasPacks = set.packs.length > 1;
        final rarities = state.availableRaritiesForGroup(activeGroup);
        final hasRarities = rarities.length > 1;
        final hasOwnership = state.availableOwnershipFilters.length > 1;
        final hasElements = state.availableElements.length > 1;
        final hasAnyFilter =
            hasPacks || hasRarities || hasOwnership || hasElements;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                canReset: state.activeFilterCount > 0,
                onReset: () => bloc.add(const FiltersCleared()),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!hasAnyFilter)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Aucun filtre disponible pour ce set.'),
                        ),
                      FilterSheetSection(
                        title: 'Booster',
                        visible: hasPacks,
                        child: PackFilterBar(
                          setName: set.name,
                          packs: set.packs,
                          selectedPack: state.selectedPack,
                          onPackSelected: (pack) =>
                              bloc.add(PackFilterChanged(pack)),
                        ),
                      ),
                      FilterSheetSection(
                        title: 'Rareté',
                        visible: hasRarities,
                        child: RarityFilterBar(
                          availableRarities: rarities,
                          selectedRarities: state.selectedRarities,
                          onSelectionChanged: (selection) =>
                              bloc.add(RarityFilterChanged(selection)),
                        ),
                      ),
                      FilterSheetSection(
                        title: 'Possession',
                        visible: hasOwnership,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OwnershipFilterBar(
                              availableFilters: state.availableOwnershipFilters,
                              selectedFilter: state.ownershipFilter,
                              onFilterSelected: (filter) =>
                                  bloc.add(OwnershipFilterChanged(filter)),
                            ),
                            if (state.ownershipFilter ==
                                OwnershipFilter.secondary)
                              SecondaryAccountFilterBar(
                                accounts: state.secondaryAccountsWithCards,
                                selectedAccountId:
                                    state.effectiveSecondaryFilterAccountId,
                                onAccountSelected: (accountId) => bloc.add(
                                  SecondaryAccountFilterChanged(accountId),
                                ),
                              ),
                          ],
                        ),
                      ),
                      FilterSheetSection(
                        title: 'Type',
                        visible: hasElements,
                        child: ElementFilterBar(
                          availableElements: state.availableElements,
                          selectedElements: state.selectedElements,
                          onSelectionChanged: (selection) =>
                              bloc.add(ElementFilterChanged(selection)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// En-tête du panneau : titre et bouton "Réinitialiser", grisé tant
/// qu'aucun filtre n'est actif.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.canReset, required this.onReset});

  final bool canReset;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filtres',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextButton(
            onPressed: canReset ? onReset : null,
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}
