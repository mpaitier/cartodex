import 'package:flutter/material.dart';

import '../../../domain/entities/collection_stats.dart';
import '../../set_detail/widgets/pack_avatar.dart';

/// Liste des boosters non complets, du moins avancé au plus avancé
/// ([CollectionStats.priorityBoosters]) — ceux à ouvrir en priorité :
/// plus un booster est loin d'être complet, plus une carte tirée
/// dedans a de chances d'être encore manquante.
class PriorityBoostersList extends StatelessWidget {
  const PriorityBoostersList({required this.boosterStats, super.key});

  final List<BoosterStats> boosterStats;

  @override
  Widget build(BuildContext context) {
    if (boosterStats.isEmpty) {
      return const Text('Tous les boosters synchronisés sont complets 🎉');
    }
    return Column(
      children: [
        for (final booster in boosterStats) _BoosterRow(booster: booster),
      ],
    );
  }
}

class _BoosterRow extends StatelessWidget {
  const _BoosterRow({required this.booster});

  final BoosterStats booster;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (booster.completionRatio * 100).toStringAsFixed(0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          PackAvatar(packName: booster.packName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booster.packName, style: theme.textTheme.bodyMedium),
                Text(booster.setName, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '${booster.owned}/${booster.total} ($percent %)',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}