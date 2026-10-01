import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/progress_count.dart';

/// Libellé "X (+Y) / Z" d'un [ProgressCount] : X en couleur du
/// compte principal (vert quand complet), "(+Y)" en jaune pour ce
/// que les secondaires ajoutent — masqué quand Y vaut 0 — et Z le
/// total.
class ProgressCountLabel extends StatelessWidget {
  const ProgressCountLabel({
    required this.progress,
    this.style,
    super.key,
  });

  final ProgressCount progress;

  /// Style de base ; le thème `bodySmall` par défaut.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodySmall;
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: '${progress.owned}',
            style: TextStyle(
              color: progress.isComplete
                  ? AppColors.complete
                  : AppColors.progressPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (progress.secondaryExtra > 0)
            TextSpan(
              text: ' (+${progress.secondaryExtra})',
              style: const TextStyle(color: AppColors.ownedBySecondaryAccount),
            ),
          TextSpan(text: ' / ${progress.total}'),
        ],
      ),
    );
  }
}