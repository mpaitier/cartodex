import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/l10n.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

/// Ligne « Se déconnecter » du compte cloud. Les comptes de jeu et la
/// possession restent sur le téléphone : seule la synchronisation
/// s'arrête.
class SignOutTile extends StatelessWidget {
  const SignOutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: Text(context.l10n.signOut),
      onTap: () =>
          context.read<AuthBloc>().add(const AuthSignOutRequested()),
    );
  }
}
