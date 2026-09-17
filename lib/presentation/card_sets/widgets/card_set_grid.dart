import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import 'card_set_grid_item.dart';

/// Grille des sets de cartes.
///
/// Extraite dans son propre composant pour garder l'écran centré
/// sur l'orchestration des états du Bloc plutôt que sur la mise en
/// page.
class CardSetGrid extends StatelessWidget {
  const CardSetGrid({required this.sets, required this.onSetTap, super.key});

  final List<CardSet> sets;
  final ValueChanged<CardSet> onSetTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        return CardSetGridItem(set: set, onTap: () => onSetTap(set));
      },
    );
  }
}