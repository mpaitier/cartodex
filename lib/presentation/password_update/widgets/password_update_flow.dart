import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import 'password_update_dialog.dart';

/// Parcours « Définir / Changer le mot de passe » des paramètres :
/// ouvre [PasswordUpdateDialog], puis confirme par une SnackBar sur
/// l'écran appelant.
abstract class PasswordUpdateFlow {
  static Future<void> start(
    BuildContext context, {
    required String email,
    required bool hasPassword,
  }) async {
    // Lus avant l'attente, pour ne pas toucher au `context` une fois
    // la popup fermée.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final saved = await PasswordUpdateDialog.show(
      context,
      email: email,
      hasPassword: hasPassword,
    );
    if (saved != true) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          hasPassword ? l10n.passwordChanged : l10n.passwordSet(email),
        ),
      ),
    );
  }
}
