import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';
import '../../account_extras/view/account_extras_page.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../widgets/account_list_item.dart';
import '../widgets/accounts_filter_action.dart';
import '../widgets/accounts_filter_sheet.dart';
import '../widgets/active_set_filter_banner.dart';
import '../widgets/add_account_dialog.dart';
import '../widgets/edit_account_dialog.dart';

/// Écran de gestion des comptes suivis par l'application.
///
/// Un compte secondaire affiche ses cartes en plus du principal ; un
/// appui dessus ouvre [AccountExtrasPage], le détail par set. Le
/// crayon de chaque ligne ouvre [EditAccountDialog] pour changer le
/// nom ou le code ami. Le bouton de la barre du haut ouvre le panneau
/// de tri et de filtre ([AccountsFilterSheet]) : le tri réordonne les
/// secondaires (le principal reste en tête) et il est mémorisé d'un
/// lancement à l'autre ; le filtre par extension (plusieurs choix
/// possibles) ne garde que les secondaires qui ont des cartes en plus
/// dans au moins l'une d'elles, rappelé par un bandeau
/// ([ActiveSetFilterBanner]).
class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountsBloc>()..add(const AccountsStarted()),
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountsBloc, AccountsState>(
      listener: (context, state) {
        // Un échec d'ajout ou de changement de principal ne
        // remplace pas toute la liste : il est signalé ici, sans
        // perturber le reste de l'écran.
        if (state.status == AccountsStatus.loaded &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'Comptes',
          actions: [
            if (state.status == AccountsStatus.loaded &&
                state.accounts.isNotEmpty)
              AccountsFilterAction(
                isFiltered: state.isSetFiltered,
                onPressed: () => _openFilterSheet(context),
              ),
          ],
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddDialog(context),
            tooltip: 'Ajouter un compte',
            child: const Icon(Icons.add),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AccountsState state) {
    if (state.status == AccountsStatus.initial ||
        state.status == AccountsStatus.loading) {
      return const AppLoadingIndicator(message: 'Chargement des comptes…');
    }

    if (state.status == AccountsStatus.error && state.accounts.isEmpty) {
      return AppErrorView(
        message: state.errorMessage ?? 'Une erreur est survenue.',
        onRetry: () =>
            context.read<AccountsBloc>().add(const AccountsStarted()),
      );
    }

    if (state.accounts.isEmpty) {
      return const Center(child: Text('Aucun compte pour l’instant.'));
    }

    // Principal en tête, secondaires triés selon le critère choisi ;
    // avec un filtre d'extension, seulement les secondaires concernés.
    final accounts = state.sortedAccounts;
    final filterSets = state.activeFilterSets;
    return Column(
      children: [
        if (filterSets.isNotEmpty)
          ActiveSetFilterBanner(
            sets: filterSets,
            onClear: () => context
                .read<AccountsBloc>()
                .add(const AccountsSetFilterChanged({})),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return AccountListItem(
                account: account,
                extras: account.isPrimary
                    ? null
                    : state.extrasByAccountId[account.id] ??
                        AccountExtras(accountId: account.id),
                focusedCounts: state.filteredCountsFor(account),
                focusedSetExtras: state.singleFilteredSetExtrasFor(account),
                onTap: account.isPrimary
                    ? null
                    : () => _openExtras(context, account),
                onCrownTap: () => context
                    .read<AccountsBloc>()
                    .add(PrimaryAccountChanged(account.id)),
                onEditTap: () => _openEditDialog(context, account),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Ouvre le panneau de tri et de filtre. Le Bloc de l'écran lui est
  /// transmis explicitement : une feuille modale ne voit pas les
  /// providers de la page.
  void _openFilterSheet(BuildContext context) {
    final bloc = context.read<AccountsBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const AccountsFilterSheet(),
      ),
    );
  }

  /// Ouvre le détail des cartes en plus de [account], puis demande au
  /// Bloc de recalculer les compteurs une fois revenu sur la liste :
  /// la possession a pu changer entre-temps (tap sur une carte dans
  /// le détail d'un set). Le Bloc est lu avant l'attente, pour ne pas
  /// toucher au `context` après la navigation.
  Future<void> _openExtras(BuildContext context, Account account) async {
    final bloc = context.read<AccountsBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountExtrasPage(account: account),
      ),
    );
    if (!bloc.isClosed) {
      bloc.add(const AccountsRefreshRequested());
    }
  }

  void _openEditDialog(BuildContext context, Account account) {
    final bloc = context.read<AccountsBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => EditAccountDialog(
        account: account,
        onSubmit: (name, gameAccountId) => bloc.add(
          AccountEdited(
            accountId: account.id,
            name: name,
            gameAccountId: gameAccountId,
          ),
        ),
      ),
    );
  }

  void _openAddDialog(BuildContext context) {
    final bloc = context.read<AccountsBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => AddAccountDialog(
        onSubmit: (name, gameAccountId) => bloc.add(
          AccountAdded(name: name, gameAccountId: gameAccountId),
        ),
      ),
    );
  }
}