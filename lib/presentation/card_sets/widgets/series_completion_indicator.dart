import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/series_overview.dart';

/// Pourcentage de complétion d'une série par le compte principal,
/// avec une fine barre en dessous. Passe en vert quand le principal
/// possède toute la série, comme les bordures de tuiles de set.
class SeriesCompletionIndicator extends StatelessWidget {
  const SeriesCompletionIndicator({required this.overview, super.key});

  final SeriesOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = overview.isPrimaryComplete
        ? AppColors.complete
        : AppColors.progressPrimary;
    final percent = (overview.primaryRatio * 100).floor();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$percent %',
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: overview.primaryRatio,
            minHeight: 3,
            color: color,
            backgroundColor: color.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}