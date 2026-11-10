import 'package:flutter/material.dart';

/// Bouton "+" de la barre du haut du détail d'un set : ajoute au
/// compte principal toutes les cartes affichées dans le volet actif,
/// après confirmation (voir `BulkAddConfirmationDialog`).
///
/// Désactivé quand il n'y a rien à ajouter ([onPressed] à `null`).
/// Composant purement visuel : l'appui remonte via [onPressed].
class BulkAddAction extends StatelessWidget {
  const BulkAddAction({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Ajouter les cartes affichées au compte principal',
      icon: const Icon(Icons.add),
    );
  }
}
