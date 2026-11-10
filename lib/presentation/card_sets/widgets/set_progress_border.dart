import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/rarity_scope.dart';
import '../../../domain/entities/set_progress.dart';
import 'set_progress_border_painter.dart';

/// Habille [child] d'une bordure qui montre la progression du set :
/// moitié gauche pour les losanges, moitié droite pour les étoiles
/// (voir [SetProgressBorderPainter]).
///
/// [child] doit être arrondi avec [cornerRadius] et prévoir une marge
/// intérieure d'au moins [strokeWidth], sinon la bordure recouvre son
/// contenu. Sans [progress], la bordure reste neutre.
///
/// La moitié exclue par [rarityScope] (périmètre de raretés global)
/// ne montre que le fond de la bordure.
class SetProgressBorder extends StatelessWidget {
  const SetProgressBorder({
    required this.child,
    this.progress,
    this.rarityScope = RarityScope.all,
    super.key,
  });

  /// Rayon des coins de la tuile, partagé avec la forme de sa `Card`.
  static const double cornerRadius = 12;

  static const double strokeWidth = 4;

  final SetProgress? progress;
  final RarityScope rarityScope;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: SetProgressBorderPainter(
        progress: progress,
        showBase: rarityScope != RarityScope.star,
        showAlternative: rarityScope != RarityScope.diamond,
        trackColor: Theme.of(context).colorScheme.outlineVariant,
        primaryColor: AppColors.progressPrimary,
        secondaryColor: AppColors.ownedBySecondaryAccount,
        completeColor: AppColors.complete,
        cornerRadius: cornerRadius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}