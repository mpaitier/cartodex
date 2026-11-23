import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../password_reset/widgets/password_reset_flow.dart';

/// Ligne « Changer le mot de passe » du compte cloud connecté.
///
/// Firebase ne permet de changer un mot de passe sans le ressaisir que
/// par un lien envoyé par email : la ligne ouvre donc la même popup que
/// « Mot de passe oublié ? », avec l'adresse du compte verrouillée.
class ChangePasswordTile extends StatelessWidget {
  const ChangePasswordTile({required this.email, super.key});

  /// Adresse du compte connecté, à laquelle le lien sera envoyé.
  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.lock_reset),
      title: Text(l10n.settingsChangePassword),
      subtitle: Text(l10n.settingsChangePasswordSubtitle),
      onTap: () => PasswordResetFlow.start(
        context,
        initialEmail: email,
        emailLocked: true,
      ),
    );
  }
}
