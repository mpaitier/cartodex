import 'package:flutter/material.dart';

import '../../../core/widgets/unique_cards_icon.dart';
import '../../../l10n/l10n.dart';

/// Bouton empreinte de la barre du haut du profil d'un compte
/// secondaire : bascule la liste entre les cartes en plus du principal
/// et les cartes qu'aucun autre compte ne possède.
///
/// Activé, il prend un fond teinté pour qu'on voie d'un coup d'œil que
/// la liste est restreinte. Composant purement visuel : l'appui
/// remonte via [onPressed].
class UniqueCardsAction extends StatelessWidget {
  const UniqueCardsAction({
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tooltip = context.l10n.uniqueCardsTooltip;
    if (selected) {
      return IconButton.filledTonal(
        onPressed: onPressed,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        icon: const UniqueCardsIcon(),
      );
    }
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: UniqueCardsIcon(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
