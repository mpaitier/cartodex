import 'package:flutter/material.dart';

/// Petit indicateur de chargement placé en fin de ligne des paramètres
/// pendant une synchronisation, à la place de l'icône habituelle.
class SettingsProgressIndicator extends StatelessWidget {
  const SettingsProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
