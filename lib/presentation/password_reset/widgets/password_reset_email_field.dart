import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Champ email de la popup de réinitialisation, avec la même
/// validation que l'écran de connexion (requis, et contient un `@`).
class PasswordResetEmailField extends StatelessWidget {
  const PasswordResetEmailField({
    required this.controller,
    required this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    super.key,
  });

  final TextEditingController controller;

  /// Appelé à la validation depuis le clavier.
  final VoidCallback onSubmitted;

  final bool enabled;

  /// Email affiché mais non modifiable (compte déjà connecté).
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.loginEmailLabel),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.send,
      autofocus: !readOnly && controller.text.isEmpty,
      enabled: enabled,
      readOnly: readOnly,
      onFieldSubmitted: (_) => onSubmitted(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return l10n.commonRequired;
        if (!value.contains('@')) return l10n.loginEmailInvalid;
        return null;
      },
    );
  }
}
