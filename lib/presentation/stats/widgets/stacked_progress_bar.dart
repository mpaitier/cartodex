import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/progress_count.dart';

/// Barre de progression en deux parties : le segment violet du
/// compte principal, prolongé par un segment jaune pour ce que les
/// comptes secondaires possèdent en plus (voir [ProgressCount]).
///
/// Mêmes couleurs que la bordure des tuiles de sets
/// (`SetProgressBorder`) : le segment du principal passe au vert
/// quand il couvre, à lui seul, tout le total.
class StackedProgressBar extends StatelessWidget {
  const StackedProgressBar({
    required this.progress,
    this.height = 8,
    super.key,
  });

  final ProgressCount progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final primaryRatio = progress.primaryRatio.clamp(0.0, 1.0);
    final combinedRatio =
        (progress.primaryRatio + progress.secondaryExtraRatio).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            _Segment(
              widthFactor: combinedRatio,
              color: AppColors.ownedBySecondaryAccount,
            ),
            _Segment(
              widthFactor: primaryRatio,
              color: progress.isComplete
                  ? AppColors.complete
                  : AppColors.progressPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.widthFactor, required this.color});

  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          heightFactor: 1,
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}