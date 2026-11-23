import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Lien « Mot de passe oublié ? » de l'écran de connexion, aligné à
/// droite sous le champ mot de passe. N'apparaît qu'en mode connexion :
/// à la création d'un compte, il n'y a pas encore de mot de passe à
/// retrouver.
class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        child: Text(context.l10n.loginForgotPassword),
      ),
    );
  }
}
