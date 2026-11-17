import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/progress_count.dart';
import '../../../domain/entities/rarity_split_progress.dart';
import 'stacked_progress_bar.dart';

/// Barre de progression d'un périmètre qui couvre les deux familles de
/// raretés, d'un seul tenant, dans cet ordre :
/// 1. losanges du compte principal (violet, vert s'il les a tous) ;
/// 2. losanges ajoutés par les secondaires (jaune) ;
/// 3. étoiles du compte principal (violet, vert s'il les a toutes) ;
/// 4. étoiles ajoutées par les secondaires (jaune) ;
/// 5. tout ce que personne ne possède, en gris, regroupé à la fin.
///
/// Le gris n'apparaît donc jamais entre les deux familles : la partie
/// remplie reste continue et se lit comme la progression globale, tout
/// en montrant d'un coup d'œil une famille complète (son segment passe
/// au vert). Chaque segment est proportionnel à son nombre de cartes.
///
/// Une famille sans aucune carte (périmètre losange ou étoile, série
/// d'une seule famille) laisse la place à une [StackedProgressBar]
/// classique pour l'autre.
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
    final segments = [
      (base.owned, _primaryColor(base)),
      (base.secondaryExtra, AppColors.ownedBySecondaryAccount),
      (alternative.owned, _primaryColor(alternative)),
      (alternative.secondaryExtra, AppColors.ownedBySecondaryAccount),
      (
        progress.combined.missing,
        Theme.of(context).colorScheme.outlineVariant,
      ),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Un segment vide n'a pas sa place dans la ligne : Expanded
            // exige une part strictement positive.
            for (final (count, color) in segments)
              if (count > 0)
                Expanded(flex: count, child: ColoredBox(color: color)),
          ],
        ),
      ),
    );
  }

  /// Vert quand le principal possède toute la famille, violet sinon :
  /// même règle que [StackedProgressBar].
  static Color _primaryColor(ProgressCount family) {
    return family.isComplete ? AppColors.complete : AppColors.progressPrimary;
  }
}
