import 'package:flutter/material.dart';

import '../../../domain/entities/app_user.dart';
import '../../../l10n/l10n.dart';
import 'delete_account_dialog.dart';

/// Parcours de suppression du compte cloud depuis les paramètres :
/// ouvre [DeleteAccountDialog], puis confirme par une SnackBar sur
/// l'écran appelant.
abstract class DeleteAccountFlow {
  static Future<void> start(
    BuildContext context, {
    required AppUser user,
  }) async {
    // Lus avant l'attente, pour ne pas toucher au `context` une fois
    // la popup fermée (l'écran des paramètres se reconstruit entre-temps,
    // l'utilisateur étant déconnecté).
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final deleted = await DeleteAccountDialog.show(context, user: user);
    if (deleted != true) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.deleteAccountDone)),
    );
  }
}
