import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import 'change_password_tile.dart';
import 'cloud_account_tile.dart';
import 'cloud_sign_in_tile.dart';
import 'delete_account_tile.dart';
import 'sign_out_tile.dart';

/// Lignes du compte cloud, selon l'état de connexion ([AuthBloc]) :
///
/// - personne de connecté : une ligne pour se connecter ;
/// - connecté : l'adresse du compte, « Changer le mot de passe » (ou
///   « Définir un mot de passe » pour un compte créé avec Google), la
///   déconnexion et la suppression du compte.
class CloudAccountSection extends StatelessWidget {
  const CloudAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    if (authState.status != AuthStatus.authenticated || user == null) {
      return const CloudSignInTile();
    }
    final email = user.email;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CloudAccountTile(user: user),
        if (email != null)
          ChangePasswordTile(
            email: email,
            hasPassword: user.hasPasswordSignIn,
          ),
        const SignOutTile(),
        DeleteAccountTile(user: user),
      ],
    );
  }
}
