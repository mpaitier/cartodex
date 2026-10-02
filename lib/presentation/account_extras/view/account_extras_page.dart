import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';
import '../../../domain/entities/card_set.dart';
import '../../set_detail/view/set_detail_page.dart';
import '../bloc/account_extras_bloc.dart';
import '../bloc/account_extras_event.dart';
import '../bloc/account_extras_state.dart';
import '../widgets/account_extras_header.dart';
import '../widgets/set_extras_list_item.dart';

/// Écran des cartes qu'un compte secondaire possède en plus du compte
/// principal : la liste des sets où le principal n'a pas une carte que
/// le secondaire a. Un appui sur un set ouvre son détail, restreint
/// aux cartes possédées par ce secondaire (voir [SetDetailPage]).
class AccountExtrasPage extends StatelessWidget {
  const AccountExtrasPage({required this.account, super.key});

  /// Le compte secondaire dont on affiche le détail.
  final Account account;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AccountExtrasBloc>()..add(AccountExtrasStarted(account.id)),
      child: _AccountExtrasView(account: account),
    );
  }
}

class _AccountExtrasView extends StatelessWidget {
  const _AccountExtrasView({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountExtrasBloc, AccountExtrasState>(
      builder: (context, state) {
        return AppScaffold(
          title: account.name,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AccountExtrasState state) {
    if (state.status == AccountExtrasStatus.initial ||
        state.status == AccountExtrasStatus.loading) {
      return const AppLoadingIndicator(message: 'Calcul en cours…');
    }

    if (state.status == AccountExtrasStatus.error) {
      return AppErrorView(
        message: state.errorMessage ?? 'Une erreur est survenue.',
        onRetry: () => context
            .read<AccountExtrasBloc>()
            .add(AccountExtrasStarted(account.id)),
      );
    }

    final extras = state.extras;
    if (extras == null || extras.bySet.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Ce compte ne possède aucune carte que le compte principal '
            "n'a pas.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      children: [
        AccountExtrasHeader(totals: extras.totals),
        for (final setExtras in extras.bySet)
          SetExtrasListItem(
            setExtras: setExtras,
            onTap: () => _openSet(context, setExtras),
          ),
      ],
    );
  }

  /// Ouvre le détail de [SetExtras.set] restreint aux cartes de
  /// [account], puis demande au Bloc de recalculer une fois revenu :
  /// la possession a pu changer entre-temps (ex : le principal vient
  /// de cocher une carte du secondaire). Le Bloc est lu avant
  /// l'attente, pour ne pas toucher au `context` après la navigation.
  Future<void> _openSet(BuildContext context, SetExtras setExtras) async {
    final bloc = context.read<AccountExtrasBloc>();
    final CardSet set = setExtras.set;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SetDetailPage(
          set: set,
          ownerFilterAccountId: account.id,
          ownerFilterAccountName: account.name,
        ),
      ),
    );
    if (!bloc.isClosed) {
      bloc.add(AccountExtrasRefreshRequested(account.id));
    }
  }
}