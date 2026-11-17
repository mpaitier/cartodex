import 'package:flutter/material.dart';

import '../../../domain/entities/rarity_split_progress.dart';
import 'stacked_progress_bar.dart';
import 'stacked_progress_fill.dart';

/// Barre de progression d'un périmètre qui couvre les deux familles de
/// raretés : une seule barre continue, avec les losanges à gauche et
/// les étoiles à droite.
///
/// Chaque partie est remplie comme une [StackedProgressBar] (voir
/// [StackedProgressFill]) : violet pour le compte principal, prolongé
/// en jaune par les secondaires, et vert dès que le principal possède à
/// lui seul toute la famille. Une série dont tous les losanges sont
/// acquis le montre donc même si les étoiles ne le sont pas. Seules
/// les deux extrémités de la barre sont arrondies : la jonction entre
/// les deux familles reste droite.
///
/// La largeur de chaque partie suit le nombre de cartes de sa famille :
/// la barre entière se lit donc toujours comme la progression globale.
/// Une famille sans aucune carte (périmètre losange ou étoile, série
/// d'une seule famille) n'a pas de partie : l'autre prend toute la
/// barre.
class RaritySplitProgressBar extends StatelessWidget {
  const RaritySplitProgressBar({
    required this.progress,
    this.height = 8,
    super.key,
  });

  final RaritySplitProgress progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final base = progress.base;
    final alternative = progress.alternative;
    if (base.total == 0 || alternative.total == 0) {
      return StackedProgressBar(
        progress: base.total == 0 ? alternative : base,
        height: height,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: base.total,
              child: StackedProgressFill(progress: base),
            ),
            Expanded(
              flex: alternative.total,
              child: StackedProgressFill(progress: alternative),
            ),
          ],
        ),
      ),
    );
  }
}
