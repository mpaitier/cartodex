import 'package:flutter/material.dart';

import '../../../domain/entities/progress_count.dart';
import '../../../l10n/l10n.dart';
import 'progress_count_label.dart';
import 'stacked_progress_bar.dart';

/// Carte de progression globale de la collection, tous sets
/// confondus : barre violette du compte principal prolongée en jaune
/// par ce que les secondaires ajoutent, le détail "X (+Y) / Z", et le
/// pourcentage du compte principal.
class OverallProgressCard extends StatelessWidget {
  const OverallProgressCard({required this.progress, super.key});

  final ProgressCount progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final percent = (progress.primaryRatio * 100)
        .toStringAsFixed(1)
        .replaceAll('.', l10n.decimalSeparator);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statsOverallTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            StackedProgressBar(progress: progress, height: 10),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProgressCountLabel(
                  progress: progress,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  l10n.percentValue(percent),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}