import 'package:flutter/material.dart';

import '../../../domain/entities/collection_stats.dart';
import 'booster_series_selector.dart';
import 'priority_boosters_list.dart';

/// Section "Boosters à ouvrir en priorité" de l'écran de
/// statistiques : titre et rappel du critère de tri, sélecteur de série
/// ([BoosterSeriesSelector]) puis la liste des boosters
/// ([PriorityBoostersList]) de la série choisie.
///
/// Ne connaît pas le Bloc : la page lui passe les données déjà
/// filtrées et remonte le choix de série via [onSeriesSelected].
class PriorityBoostersSection extends StatelessWidget {
  const PriorityBoostersSection({
    required this.series,
    required this.selectedSeriesKey,
    required this.setProgress,
    required this.onSeriesSelected,
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

  String get _emptyMessage => selectedSeriesKey == null
      ? 'Tous les boosters synchronisés sont complets 🎉'
      : 'Tous les boosters de cette série sont complets 🎉';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Boosters à ouvrir en priorité',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          'Classés selon le nombre moyen de cartes manquantes obtenues '
          'par ouverture, d’après les taux de tirage du jeu.',
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
          emptyMessage: _emptyMessage,
        ),
      ],
    );
  }
}
