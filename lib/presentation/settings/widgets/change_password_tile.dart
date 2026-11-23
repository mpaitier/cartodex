import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../password_update/widgets/password_update_flow.dart';

/// Ligne du compte cloud connecté pour changer ou définir le mot de
/// passe, directement dans l'app ([PasswordUpdateFlow]).
///
/// Un compte créé avec Google n'a pas encore de mot de passe : la ligne
/// devient « Définir un mot de passe », et le mot de passe saisi est lié
/// au même compte, qui peut ensuite se connecter par Google ou par
/// email. Un lien de réinitialisation par email ne marche pas dans ce
/// cas : Firebase le refuse pour un compte sans mot de passe.
class ChangePasswordTile extends StatelessWidget {
  const ChangePasswordTile({
    required this.email,
    required this.hasPassword,
    super.key,
  });

  /// Adresse du compte connecté, qui servira d'identifiant avec le mot
  /// de passe.
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
      subtitle: hasPassword ? null : Text(l10n.settingsSetPasswordSubtitle),
      onTap: () => PasswordUpdateFlow.start(
        context,
        email: email,
        hasPassword: hasPassword,
      ),
    );
  }
}
