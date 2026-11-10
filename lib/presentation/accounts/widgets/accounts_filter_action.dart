import 'package:flutter/material.dart';

/// Bouton de la barre du haut de l'onglet des comptes : ouvre le
/// panneau de tri ([AccountsFilterSheet][accounts_filter_sheet.dart]).
///
/// Composant purement visuel : l'appui remonte via [onPressed].
class AccountsFilterAction extends StatelessWidget {
  const AccountsFilterAction({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Trier',
      icon: const Icon(Icons.tune),
    );
  }
}
