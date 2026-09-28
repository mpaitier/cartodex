import 'package:flutter/material.dart';

/// Bouton de connexion Google, extrait en composant dédié pour
/// rester réutilisable si [LoginPage][../view/login_page.dart]
/// évolue vers plusieurs mises en page.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.login),
      label: const Text('Continuer avec Google'),
    );
  }
}