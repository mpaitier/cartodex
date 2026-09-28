import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/view/login_page.dart';

/// Action d'AppBar pour la synchronisation avec le compte
/// applicatif (Firebase).
///
/// Tant qu'aucun compte n'est connecté, ouvre [LoginPage]. Une fois
/// connecté, propose de synchroniser ou de se déconnecter — la
/// synchronisation des données elle-même (comptes Pokémon et
/// possession) arrive dans une étape ultérieure : pour l'instant,
/// "Synchroniser maintenant" ne fait que le signaler, plutôt que de
/// laisser croire à une action qui n'existe pas encore.
class SyncFirebaseAction extends StatelessWidget {
  const SyncFirebaseAction({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status != AuthStatus.authenticated) {
          return IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            ),
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Se connecter pour synchroniser',
          );
        }
        return PopupMenuButton<_SyncMenuAction>(
          icon: const Icon(Icons.cloud_done_outlined),
          tooltip: 'Synchronisation',
          onSelected: (action) => _onMenuAction(context, action),
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
  }

  void _onMenuAction(BuildContext context, _SyncMenuAction action) {
    switch (action) {
      case _SyncMenuAction.sync:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La synchronisation des données arrive dans une prochaine étape.',
            ),
          ),
        );
      case _SyncMenuAction.signOut:
        context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }
}

enum _SyncMenuAction { sync, signOut }