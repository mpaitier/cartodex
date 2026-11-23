import 'package:flutter/material.dart';

/// Message d'échec affiché sous le champ email de la popup de
/// réinitialisation. Gardé dans la popup plutôt qu'en SnackBar, qui
/// s'afficherait derrière elle.
class PasswordResetErrorText extends StatelessWidget {
  const PasswordResetErrorText({required this.message, super.key});

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
