import 'package:flutter/material.dart';

import '../../../domain/entities/collection_stats.dart';

/// Une ligne de progression par série ([CollectionStats.seriesStats]),
/// dans le même ordre que `SeriesFilterBar` de `CardSetsPage`
/// (séries lettrées les plus récentes en premier, "Promo" en
/// dernier).
class SeriesProgressList extends StatelessWidget {
  const SeriesProgressList({required this.seriesStats, super.key});

  final List<SeriesStats> seriesStats;

  @override
  Widget build(BuildContext context) {
    if (seriesStats.isEmpty) {
      return const Text('Aucune série synchronisée pour l’instant.');
    }
    return Column(
      children: [
        for (final series in seriesStats) _SeriesRow(series: series),
      ],
    );
  }
}

class _SeriesRow extends StatelessWidget {
  const _SeriesRow({required this.series});

  final SeriesStats series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(series.label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: series.completionRatio,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${series.owned}/${series.total}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}