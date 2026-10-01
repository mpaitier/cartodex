import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../../domain/entities/set_progress.dart';
import 'card_set_grid_item.dart';

/// Grille des sets de cartes.
///
/// Extraite dans son propre composant pour garder l'écran centré
/// sur l'orchestration des états du Bloc plutôt que sur la mise en
/// page. [progressBySetId] est indexé par identifiant de set ; un
/// set absent de la table s'affiche sans progression.
class CardSetGrid extends StatelessWidget {
  const CardSetGrid({
    required this.sets,
    required this.onSetTap,
    this.progressBySetId = const {},
    super.key,
  });

  final List<CardSet> sets;
  final ValueChanged<CardSet> onSetTap;
  final Map<String, SetProgress> progressBySetId;

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
        return CardSetGridItem(
          set: set,
          progress: progressBySetId[set.id],
          onTap: () => onSetTap(set),
        );
      },
    );
  }
}