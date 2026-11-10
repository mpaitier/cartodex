import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/accounts_sort_option.dart';
import '../../../l10n/l10n.dart';
import '../../set_detail/widgets/filter_chip_wrap.dart';
import '../../set_detail/widgets/filter_sheet_section.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import 'accounts_sort_option_label.dart';
import 'set_filter_tile.dart';

/// Panneau de tri et de filtre de l'onglet des comptes, ouvert depuis
/// le bouton de la barre du haut (`AccountsFilterAction`).
///
/// Même présentation que le panneau de filtres du détail d'un set
/// (rubriques [FilterSheetSection], puces qui passent à la ligne
/// [FilterChipWrap]) :
/// - "Trier par" : ordre de création, alphabétique ou cartes en plus ;
/// - "Extension" : "Toutes", puis le logo de chaque extension où au
///   moins un secondaire a des cartes en plus ([SetFilterTile]).
///   Multi-sélection : chaque appui coche ou décoche une extension, et
///   "Toutes" retire le filtre.
///
/// Suit l'état de [AccountsBloc] en direct : la liste derrière le
/// panneau se met à jour à chaque choix. L'appelant doit fournir le
/// Bloc de l'écran (`BlocProvider.value`), une feuille modale ne voyant
/// pas les providers de la page.
class AccountsFilterSheet extends StatelessWidget {
  const AccountsFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final bloc = context.read<AccountsBloc>();
        final sets = state.availableFilterSets;
        final activeSetIds = {
          for (final set in state.activeFilterSets) set.id,
        };

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  l10n.accountsSortAndFilter,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilterSheetSection(
                        title: l10n.accountsSortBy,
                        child: FilterChipWrap(
                          itemCount: AccountsSortOption.values.length,
                          itemBuilder: (context, index) {
                            final option = AccountsSortOption.values[index];
                            return ChoiceChip(
                              label: Text(option.label(l10n)),
                              selected: option == state.sortOption,
                              showCheckmark: false,
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              visualDensity: VisualDensity.compact,
                              onSelected: (_) =>
                                  bloc.add(AccountsSortChanged(option)),
                            );
                          },
                        ),
                      ),
                      FilterSheetSection(
                        title: l10n.accountsSetFilterSection,
                        visible: sets.isNotEmpty,
                        child: FilterChipWrap(
                          itemCount: sets.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return ChoiceChip(
                                label: Text(l10n.commonAllFeminine),
                                selected: activeSetIds.isEmpty,
                                showCheckmark: false,
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                visualDensity: VisualDensity.compact,
                                onSelected: (_) => bloc
                                    .add(const AccountsSetFilterChanged({})),
                              );
                            }
                            final set = sets[index - 1];
                            final selected = activeSetIds.contains(set.id);
                            return SetFilterTile(
                              set: set,
                              selected: selected,
                              onTap: () {
                                final updated = Set<String>.from(activeSetIds);
                                if (selected) {
                                  updated.remove(set.id);
                                } else {
                                  updated.add(set.id);
                                }
                                bloc.add(AccountsSetFilterChanged(updated));
                              },
                            );
                          },
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
