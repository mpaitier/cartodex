import 'package:flutter/material.dart';

/// Message d'échec affiché en bas d'un formulaire de popup (mot de
/// passe oublié, mot de passe des paramètres). Gardé dans la popup
/// plutôt qu'en SnackBar, qui s'afficherait derrière elle.
class FormErrorText extends StatelessWidget {
  const FormErrorText({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
