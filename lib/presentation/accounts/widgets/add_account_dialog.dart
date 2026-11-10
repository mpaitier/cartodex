import 'package:flutter/material.dart';

import 'account_form_dialog.dart';

/// Popup de création d'un compte, champs vides au départ (voir
/// [AccountFormDialog]).
class AddAccountDialog extends StatelessWidget {
  const AddAccountDialog({required this.onSubmit, super.key});

  final void Function(String name, String gameAccountId) onSubmit;

  @override
  Widget build(BuildContext context) {
    return AccountFormDialog(
      title: 'Ajouter un compte',
      submitLabel: 'Ajouter',
      onSubmit: onSubmit,
    );
  }
}
