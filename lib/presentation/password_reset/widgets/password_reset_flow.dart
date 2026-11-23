import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import 'password_reset_dialog.dart';

/// Parcours « Mot de passe oublié ? » de l'écran de connexion : ouvre
/// [PasswordResetDialog], puis confirme l'envoi par une SnackBar sur
/// l'écran appelant.
abstract class PasswordResetFlow {
  static Future<void> start(
    BuildContext context, {
    String? initialEmail,
  }) async {
    // Lus avant l'attente, pour ne pas toucher au `context` une fois
    // la popup fermée.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final sentTo = await PasswordResetDialog.show(
      context,
      initialEmail: initialEmail,
    );
    if (sentTo == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.passwordResetSent(sentTo))),
    );
  }
}
