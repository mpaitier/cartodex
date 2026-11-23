import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../password_reset/widgets/password_reset_flow.dart';

/// Ligne du compte cloud connecté pour changer ou définir le mot de
/// passe.
///
/// Firebase ne permet de changer un mot de passe sans le ressaisir que
/// par un lien envoyé par email : la ligne ouvre donc la même popup que
/// « Mot de passe oublié ? », avec l'adresse du compte verrouillée.
///
/// Un compte créé avec Google n'a pas encore de mot de passe : la ligne
/// devient « Définir un mot de passe ». Le lien en ajoute un au même
/// compte (les comptes Firebase sont associés par adresse email), qui
/// peut ensuite se connecter par Google ou par email.
class ChangePasswordTile extends StatelessWidget {
  const ChangePasswordTile({
    required this.email,
    required this.hasPassword,
    super.key,
  });

  /// Adresse du compte connecté, à laquelle le lien sera envoyé.
  final String email;

  /// `true` si le compte a déjà un mot de passe (voir
  /// `AppUser.hasPasswordSignIn`).
  final bool hasPassword;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: Icon(hasPassword ? Icons.lock_reset : Icons.password),
      title: Text(
        hasPassword ? l10n.settingsChangePassword : l10n.settingsSetPassword,
      ),
      subtitle: Text(
        hasPassword
            ? l10n.settingsChangePasswordSubtitle
            : l10n.settingsSetPasswordSubtitle,
      ),
      onTap: () => PasswordResetFlow.start(
        context,
        initialEmail: email,
        emailLocked: true,
      ),
    );
  }
}
