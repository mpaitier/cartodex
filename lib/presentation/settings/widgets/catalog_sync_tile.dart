import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/l10n.dart';
import '../../card_sets/bloc/card_sets_bloc.dart';
import '../../card_sets/bloc/card_sets_event.dart';
import '../../card_sets/bloc/card_sets_state.dart';
import 'settings_progress_indicator.dart';

/// Ligne « Synchroniser le référentiel ».
///
/// Passe par le [CardSetsBloc] de l'accueil (transmis à l'écran des
/// paramètres) : une fois le référentiel téléchargé, l'accueil est
/// déjà à jour au retour. La ligne se désactive pendant la
/// synchronisation, pour empêcher un second lancement, et confirme
/// l'issue par une SnackBar.
class CatalogSyncTile extends StatelessWidget {
  const CatalogSyncTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardSetsBloc, CardSetsState>(
      listenWhen: (previous, current) =>
          previous.status == CardSetsStatus.syncing &&
          current.status != CardSetsStatus.syncing,
      listener: _onSyncFinished,
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        final l10n = context.l10n;
        final isSyncing = state.status == CardSetsStatus.syncing;
        return ListTile(
          leading: const Icon(Icons.sync),
          title: Text(l10n.syncCatalog),
          subtitle: Text(l10n.settingsCatalogSubtitle),
          trailing: isSyncing ? const SettingsProgressIndicator() : null,
          enabled: !isSyncing,
          onTap: () => context
              .read<CardSetsBloc>()
              .add(const CardSetsSyncRequested()),
        );
      },
    );
  }

  void _onSyncFinished(BuildContext context, CardSetsState state) {
    final l10n = context.l10n;
    final message = state.status == CardSetsStatus.error
        ? state.errorMessage ?? l10n.genericError
        : l10n.settingsCatalogUpToDate;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
