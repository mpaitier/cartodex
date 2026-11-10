import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import 'account_form_dialog.dart';

/// Popup de création d'un compte, champs vides au départ (voir
/// [AccountFormDialog]).
class AddAccountDialog extends StatelessWidget {
  const AddAccountDialog({required this.onSubmit, super.key});

  final void Function(String name, String gameAccountId) onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AccountFormDialog(
      title: l10n.addAccountTitle,
      submitLabel: l10n.commonAdd,
      onSubmit: onSubmit,
    );
  }
}
