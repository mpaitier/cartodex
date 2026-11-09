import 'package:flutter/material.dart';

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

  /// Deux décimales, virgule à la française. Les valeurs vont de
  /// quelques centièmes (set presque complet) au nombre de cartes du
  /// booster (tout manque).
  String get _formatted =>
      expectedNewCards.toStringAsFixed(2).replaceAll('.', ',');

  /// Singulier en dessous de 2, comme le veut l'usage en français
  /// ("0,5 carte", "1,5 carte", "2 cartes").
  String get _noun =>
      expectedNewCards < 2 ? 'carte nouvelle' : 'cartes nouvelles';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      '≈ $_formatted $_noun par ouverture',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
