import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Le nombre moyen de cartes manquantes qu'une ouverture rapporte,
/// sous le nom d'un booster prioritaire (ex: "≈ 0,42 carte nouvelle
/// par ouverture").
///
/// C'est le critère de tri de la liste (voir
/// `CollectionStats.priorityBoosterProgressFor`) : l'afficher rend
/// l'ordre lisible au lieu de le laisser deviner.
class ExpectedNewCardsLabel extends StatelessWidget {
  const ExpectedNewCardsLabel({required this.expectedNewCards, super.key});

  final double expectedNewCards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    // Deux décimales, avec le séparateur de la langue. Les valeurs vont
    // de quelques centièmes (set presque complet) au nombre de cartes
    // du booster (tout manque).
    final formatted = expectedNewCards
        .toStringAsFixed(2)
        .replaceAll('.', l10n.decimalSeparator);
    // Le pluriel se décide sur la partie entière : en français, le
    // singulier vaut pour tout ce qui est sous 2 ("0,5 carte", "1,5
    // carte", "2 cartes"), ce qui correspond à la catégorie "one" des
    // entiers 0 et 1. L'anglais garde toujours le pluriel avec des
    // décimales (voir la clé `expectedNewCards` des fichiers ARB).
    return Text(
      l10n.expectedNewCards(expectedNewCards.floor(), formatted),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
