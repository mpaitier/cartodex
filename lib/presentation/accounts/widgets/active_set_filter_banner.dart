import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../card_sets/widgets/card_set_logo.dart';

/// Bandeau en haut de la liste des comptes quand un filtre par
/// extension est actif : rappelle l'extension choisie et permet de
/// retirer le filtre sans rouvrir le panneau ([onClear]).
class ActiveSetFilterBanner extends StatelessWidget {
  const ActiveSetFilterBanner({
    required this.set,
    required this.onClear,
    super.key,
  });

  final CardSet set;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 28,
              child: CardSetLogo(url: set.logoUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cartes en plus dans ${set.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              onPressed: onClear,
              tooltip: 'Retirer le filtre',
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
