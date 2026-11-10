import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

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
      tooltip: context.l10n.bulkAddTooltip,
      icon: const Icon(Icons.add),
    );
  }
}
