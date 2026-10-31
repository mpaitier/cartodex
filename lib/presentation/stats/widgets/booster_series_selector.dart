import 'package:flutter/material.dart';

import '../../../domain/entities/collection_stats.dart';
import 'booster_series_chip.dart';

/// Rangée de puces pour choisir la série dont on veut voir les
/// boosters à ouvrir en priorité : "Toutes" puis une puce par série
/// de [series] (voir `CollectionStats.boosterSeries`), dans le même
/// ordre que la liste "Par série".
///
/// Défile horizontalement si les séries ne tiennent pas sur la
/// largeur. Se rend invisible quand il n'y a qu'une série : "Toutes"
/// et cette série donneraient la même liste.
class BoosterSeriesSelector extends StatelessWidget {
  const BoosterSeriesSelector({
    required this.series,
    required this.selectedKey,
    required this.onSelected,
    super.key,
  });

  final List<SeriesStats> series;

  /// `null` quand "Toutes" est sélectionné.
  final String? selectedKey;

  /// Reçoit la clé de la série choisie, ou `null` pour "Toutes".
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (series.length <= 1) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          BoosterSeriesChip(
            label: 'Toutes',
            selected: selectedKey == null,
            onSelected: () => onSelected(null),
          ),
          for (final item in series) ...[
            const SizedBox(width: 8),
            BoosterSeriesChip(
              label: item.label,
              selected: item.seriesKey == selectedKey,
              onSelected: () => onSelected(item.seriesKey),
            ),
          ],
        ],
      ),
    );
  }
}
