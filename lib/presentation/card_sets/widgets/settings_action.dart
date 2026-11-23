import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Action d'AppBar de l'accueil qui ouvre l'écran des paramètres
/// (comptes TCG Pocket, synchronisations, compte cloud, langue).
class SettingsAction extends StatelessWidget {
  const SettingsAction({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.settings_outlined),
      tooltip: context.l10n.settingsTitle,
    );
  }
}
