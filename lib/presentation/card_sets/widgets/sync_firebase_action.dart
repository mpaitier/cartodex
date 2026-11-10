import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/sync_result.dart';
import '../../../l10n/l10n.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/view/login_page.dart';
import '../../sync/bloc/sync_bloc.dart';
import '../../sync/bloc/sync_event.dart';
import '../../sync/bloc/sync_state.dart';

/// Action d'AppBar pour la synchronisation avec le compte
/// applicatif (Firebase).
///
/// Tant qu'aucun compte n'est connecté, ouvre [LoginPage]. Une fois
/// connecté, propose de synchroniser (délègue à [SyncBloc], qui
/// applique `SyncWithCloud` — comptes Pokémon et possession, règle
/// "possédée l'emporte toujours") ou de se déconnecter.
class SyncFirebaseAction extends StatelessWidget {
  const SyncFirebaseAction({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncBloc, SyncState>(
      listener: (context, state) {
        if (state.status == SyncStatus.success && state.result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_successMessage(context.l10n, state.result!)),
            ),
          );
        }
        if (state.status == SyncStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final l10n = context.l10n;
          if (authState.status != AuthStatus.authenticated) {
            return IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              ),
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: l10n.signInToSyncTooltip,
            );
          }
          return BlocBuilder<SyncBloc, SyncState>(
            builder: (context, syncState) {
              if (syncState.status == SyncStatus.syncing) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return PopupMenuButton<_SyncMenuAction>(
                icon: const Icon(Icons.cloud_done_outlined),
                tooltip: l10n.syncMenuTooltip,
                onSelected: (action) =>
                    _onMenuAction(context, action, authState),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _SyncMenuAction.sync,
                    child: Text(l10n.syncNow),
                  ),
                  PopupMenuItem(
                    value: _SyncMenuAction.signOut,
                    child: Text(l10n.signOut),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Bilan de la synchronisation (ex: "2 comptes récupérés, 14 cartes
  /// envoyées"), avec un pluriel propre à chaque langue.
  String _successMessage(AppLocalizations l10n, SyncResult result) {
    if (result.isEmpty) return l10n.syncUpToDate;
    final parts = <String>[
      if (result.accountsPulled > 0)
        l10n.syncAccountsPulled(result.accountsPulled),
      if (result.accountsPushed > 0)
        l10n.syncAccountsPushed(result.accountsPushed),
      if (result.cardsPulled > 0) l10n.syncCardsPulled(result.cardsPulled),
      if (result.cardsPushed > 0) l10n.syncCardsPushed(result.cardsPushed),
    ];
    return parts.join(', ');
  }

  void _onMenuAction(
    BuildContext context,
    _SyncMenuAction action,
    AuthState authState,
  ) {
    switch (action) {
      case _SyncMenuAction.sync:
        final userId = authState.user?.uid;
        if (userId != null) {
          context.read<SyncBloc>().add(SyncRequested(userId));
        }
      case _SyncMenuAction.signOut:
        context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }
}

enum _SyncMenuAction { sync, signOut }