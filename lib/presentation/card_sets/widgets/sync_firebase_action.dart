import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/sync_result.dart';
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
            SnackBar(content: Text(_successMessage(state.result!))),
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
          if (authState.status != AuthStatus.authenticated) {
            return IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              ),
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: 'Se connecter pour synchroniser',
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
                tooltip: 'Synchronisation',
                onSelected: (action) =>
                    _onMenuAction(context, action, authState),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _SyncMenuAction.sync,
                    child: Text('Synchroniser maintenant'),
                  ),
                  const PopupMenuItem(
                    value: _SyncMenuAction.signOut,
                    child: Text('Se déconnecter'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _successMessage(SyncResult result) {
    if (result.isEmpty) return 'Déjà à jour.';
    final parts = <String>[
      if (result.accountsPulled > 0)
        '${result.accountsPulled} compte(s) récupéré(s)',
      if (result.accountsPushed > 0)
        '${result.accountsPushed} compte(s) envoyé(s)',
      if (result.cardsPulled > 0)
        '${result.cardsPulled} carte(s) récupérée(s)',
      if (result.cardsPushed > 0)
        '${result.cardsPushed} carte(s) envoyée(s)',
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