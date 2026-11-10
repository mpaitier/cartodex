import 'package:flutter/material.dart';

import '../../../domain/entities/account.dart';
import '../../../l10n/l10n.dart';
import 'account_form_dialog.dart';

/// Popup de modification d'un compte, ouverte par le bouton crayon de
/// la liste : nom et code ami pré-remplis avec les valeurs actuelles
/// de [account] (voir [AccountFormDialog]).
///
/// Le rôle du compte (principal ou non) ne se change pas ici, mais
/// avec l'étoile de la liste.
class EditAccountDialog extends StatelessWidget {
  const EditAccountDialog({
    required this.account,
    required this.onSubmit,
    super.key,
  });

  final Account account;
  final void Function(String name, String gameAccountId) onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AccountFormDialog(
      title: l10n.editAccountTitle,
      submitLabel: l10n.commonSave,
      initialName: account.name,
      initialGameAccountId: account.gameAccountId,
      onSubmit: onSubmit,
    );
  }
}
