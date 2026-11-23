import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import 'password_reset_dialog.dart';

/// Parcours complet de réinitialisation : ouvre [PasswordResetDialog],
/// puis confirme l'envoi par une SnackBar sur l'écran appelant.
///
/// Partagé par « Mot de passe oublié ? » (écran de connexion) et
/// « Changer le mot de passe » (paramètres), pour que les deux
/// affichent la même confirmation.
abstract class PasswordResetFlow {
  static Future<void> start(
    BuildContext context, {
    String? initialEmail,
    bool emailLocked = false,
  }) async {
    // Lus avant l'attente, pour ne pas toucher au `context` une fois
    // la popup fermée.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final sentTo = await PasswordResetDialog.show(
      context,
      initialEmail: initialEmail,
      emailLocked: emailLocked,
    );
    if (sentTo == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.passwordResetSent(sentTo))),
    );
  }
}
