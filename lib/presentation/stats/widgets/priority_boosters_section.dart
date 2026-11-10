import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../../domain/entities/collection_stats.dart';
import '../../../l10n/l10n.dart';
import 'booster_series_selector.dart';
import 'priority_boosters_list.dart';

/// Section "Boosters à ouvrir en priorité" de l'écran de
/// statistiques : titre et rappel du critère de tri, sélecteur de série
/// ([BoosterSeriesSelector]) puis la liste des boosters
/// ([PriorityBoostersList]) de la série choisie.
///
/// Ne connaît pas le Bloc : la page lui passe les données déjà
/// filtrées, et remonte le choix de série via [onSeriesSelected] et
/// l'appui sur un set ou un booster via [onSetTap].
class PriorityBoostersSection extends StatelessWidget {
  const PriorityBoostersSection({
    required this.series,
    required this.selectedSeriesKey,
    required this.setProgress,
    required this.onSeriesSelected,
    required this.onSetTap,
    super.key,
  });

  /// Séries proposées dans le sélecteur.
  final List<SeriesStats> series;

  /// Série affichée, `null` pour toutes les séries.
  final String? selectedSeriesKey;

  /// Boosters à ouvrir en priorité, déjà restreints à
  /// [selectedSeriesKey].
  final List<SetBoosterProgress> setProgress;

  final ValueChanged<String?> onSeriesSelected;

  /// Set à ouvrir, depuis sa ligne ou celle de l'un de ses boosters.
  final ValueChanged<CardSet> onSetTap;

  String _emptyMessage(AppLocalizations l10n) => selectedSeriesKey == null
      ? l10n.priorityBoostersAllComplete
      : l10n.priorityBoostersSeriesComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.priorityBoostersTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          l10n.priorityBoostersSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        BoosterSeriesSelector(
          series: series,
          selectedKey: selectedSeriesKey,
          onSelected: onSeriesSelected,
        ),
        PriorityBoostersList(
          setProgress: setProgress,
          emptyMessage: _emptyMessage(l10n),
          onSetTap: onSetTap,
        ),
      ],
    );
  }
}
