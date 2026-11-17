import 'package:flutter/material.dart';

import '../../../domain/entities/rarity_split_progress.dart';
import 'stacked_progress_bar.dart';

/// Barre de progression du périmètre Σ, coupée en deux : une barre
/// pour les losanges à gauche, une pour les étoiles à droite.
///
/// Chaque barre est une [StackedProgressBar] : violet pour le compte
/// principal, prolongé en jaune par les secondaires, et vert dès que le
/// principal possède à lui seul toute la famille. Une série dont tous
/// les losanges sont acquis le montre donc même si les étoiles ne le
/// sont pas.
///
/// La largeur de chaque barre suit le nombre de cartes de sa famille :
/// mises bout à bout, les deux barres se lisent comme la progression
/// globale, et une famille plus grande pèse plus. Une famille sans
/// aucune carte n'a pas de barre ; l'autre prend alors toute la place.
class RaritySplitProgressBar extends StatelessWidget {
  const RaritySplitProgressBar({
    required this.progress,
    this.height = 8,
    this.gap = 4,
    super.key,
  });

  final RaritySplitProgress progress;
  final double height;

  /// Espace entre la barre des losanges et celle des étoiles.
  final double gap;

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
    return Row(
      children: [
        Expanded(
          flex: base.total,
          child: StackedProgressBar(progress: base, height: height),
        ),
        SizedBox(width: gap),
        Expanded(
          flex: alternative.total,
          child: StackedProgressBar(progress: alternative, height: height),
        ),
      ],
    );
  }
}
